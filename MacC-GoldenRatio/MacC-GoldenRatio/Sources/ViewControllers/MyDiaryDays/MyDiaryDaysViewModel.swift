//
//  MyDiaryDaysViewModel.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/11/10.
//

import RxCocoa
import RxSwift

class MyDiaryDaysViewModel {
    
    let albumCollectionViewModel = AlbumCollectionViewModel()
    
    let segmentIndex = BehaviorRelay<Int>(value: 0)
    let selectedViewType: Driver<[Bool]>
    
    init(diary: Diary) {
        
        self.selectedViewType = segmentIndex
            .map{ isHidden in
                var array = [Bool](repeating: true, count: 3)
                array[isHidden] = false
                return array
            }
            .asDriver(onErrorJustReturn: [Bool](repeating: false, count: 3))
        
        self.albumCollectionViewModel.collectionDiaryData.onNext(diary)
    }
}
