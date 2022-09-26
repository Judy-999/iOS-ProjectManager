//
//  WorkViewModel.swift
//  ProjectManager
//
//  Created by Judy on 2022/09/07.
//

import RxSwift
import RxCocoa

final class WorkViewModel {
    private var database: DatabaseManageable
    private let disposeBag = DisposeBag()
    private let works = BehaviorSubject<[Work]>(value: [])
    let worksObservable: Observable<[Work]>
    let histories = BehaviorSubject<[String]>(value: [])
    
    init(dbType: DatabaseManageable) {
        database = dbType
        
        database.fetchWork()
            .subscribe(onNext: works.onNext)
            .disposed(by: disposeBag)
        
        worksObservable = works
    }
    
    func changeDatabase(_ isConnected: Bool) {
        if isConnected {
            database = FirebaseManager.shared
            backupWorks()
        } else {
            database = CoreDataManager.shared
        }
    }
    
    private func backupWorks() {
        CoreDataManager.shared.fetchWork()
            .subscribe(onNext: {
                $0.forEach {
                    FirebaseManager.shared.saveWork($0)
                    CoreDataManager.shared.deleteWork(id: $0.id)
                }
            }).disposed(by: disposeBag)
    }
    
    func selectWork(id: UUID) -> Work? {
        guard let value = try? works.value() else { return nil }
        
        let selectedWork = value.filter {
            $0.id == id
        }
        
        return selectedWork.first
    }
    
    func addWork(_ work: Work) {
        database.saveWork(work)
        guard let value = try? works.value() else { return }
        
        works.onNext([work] + value)
        
        histories
            .take(1)
            .observe(on: MainScheduler.instance)
            .subscribe {
            self.histories.onNext($0 + ["Added '\(work.title)'."])
        }.disposed(by: disposeBag)
    }
    
    func editWork(_ work: Work, newWork: Work) {
        database.saveWork(newWork)
        
        works.map {
            $0.map {
                return $0.id == work.id ? newWork : $0
            }
        }.observe(on: MainScheduler.asyncInstance)
            .take(1)
            .subscribe(onNext: {
                self.works.onNext($0)
            }).disposed(by: disposeBag)

        histories.take(1)
            .observe(on: MainScheduler.instance)
            .subscribe {
            self.histories.onNext($0 + ["Edited '\(work.title)'."])
        }.disposed(by: disposeBag)
    }
    
    func deleteWork(id: UUID) {
        database.deleteWork(id: id)
        
        works.map {
            $0.filter { $0.id != id }
        }
        .take(1)
        .observe(on: MainScheduler.instance)
        .subscribe(onNext: {
            self.works.onNext($0)
        }).disposed(by: disposeBag)
        
        guard let work = selectWork(id: id) else { return }
        
        histories.take(1)
            .observe(on: MainScheduler.instance)
            .subscribe {
            self.histories.onNext($0 + ["Removed '\(work.title)'."])
        }.disposed(by: disposeBag)
    }
    
    func changeWorkState(_ work: Work, to state: WorkState) {
        let changedWork = Work(id: work.id,
                               title: work.title,
                               content: work.content,
                               deadline: work.deadline,
                               state: state)
        
        database.saveWork(changedWork)
        
        works.map {
            $0.map {
                $0.id == work.id ? changedWork : $0
            }
        }.take(1)
        .observe(on: MainScheduler.asyncInstance)
        .subscribe(onNext: {
            self.works.onNext($0)
        }).disposed(by: disposeBag)
        
        histories
            .take(1)
            .observe(on: MainScheduler.instance)
            .subscribe {
            self.histories.onNext($0 + ["Moved '\(work.title)' from \(work.state.rawValue) to \(state.rawValue)."])
        }.disposed(by: disposeBag)
    }
}
