//
//  MyDiariesViewModel.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/10/04.
//

import FirebaseAuth
import FirebaseFirestore
import RxCocoa
import RxSwift

// TODO: 수정 예정
class MyHomeViewModel {
	private let client = FirestoreClient()
	private let db = Firestore.firestore()
	private let disposeBag = DisposeBag()
	
	private var myUID = Auth.auth().currentUser?.uid ?? ""
	
	let diaryCollectionViewModel = DiaryCollectionViewModel()
	
	var isEqual = false
	var isInitializing = true {
		didSet {
			if isInitializing {
				LoadingIndicator.showLoading(loadingText: "다이어리를 불러오는 중입니다.")
			} else {
				LoadingIndicator.hideLoading()
			}
		}
	}
	
	init() {
		createCell()
	}
	
	func createCell() {
		let userUID = Observable.just(Auth.auth().currentUser?.uid ?? "")
		
		let diaryResult = userUID
			.flatMapLatest(client.fetchMyDiaries)
			.share()
		
		let diaryValue = diaryResult
			.map(getDiaryValue)
			.filter { $0 != nil }

		let diaryData = diaryValue
			.map(getCollectionCellData)
		
		diaryData
			.map(getCollectionSection)
			.bind(to: diaryCollectionViewModel.collectionDiaryData)
			.disposed(by: disposeBag)
	}
	
	func getDiaryValue(_ result: Result<[Diary], Error>) -> [Diary]? {
		guard case .success(let value) = result else {
			return nil
		}
		return value
	}
	
	func getCollectionCellData(_ value: [Diary]?) -> [DiaryCell] {
		guard let value = value else {
			return []
		}
		
		return value.map {
			DiaryCell(diaryUUID: $0.diaryUUID, diaryName: $0.diaryName, diaryCover: $0.diaryCover)
		}
	}
	
	func getCollectionSection(_ value: [DiaryCell]?) -> [DiarySection] {
		guard let value = value else {
			return []
		}
		
		return [DiarySection(header: "다이어리", items: value)]
	}
	
	func isDiaryCodeEqualTo(_ diaryUUID: String) {
		Task {
			do {
				self.isEqual = try await client.isDiaryCodeEqualTo(diaryUUID)
			} catch {
				print(error)
			}
		}
	}
	
	func updateJoinDiary(_ diaryUUID: String) {
		db.collection("Diary").document(diaryUUID).updateData(["userUIDs": FieldValue.arrayUnion([myUID])])
	}
}
