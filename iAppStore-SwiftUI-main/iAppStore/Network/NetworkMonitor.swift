//
//  NetworkMonitor.swift
//  iAppStore
//
//  Created by peak on 2022/1/27.
//  Copyright © 2022 37 Mobile Games. All rights reserved.
//

import Foundation
import Network
import Combine
import SwiftUI

@MainActor
final class NetworkStateChecker: ObservableObject {
    static let shared = NetworkStateChecker()
    private(set) lazy var publisher = makePublisher()
    @Published private(set) var path: NWPath
    
    private let monitor: NWPathMonitor
    private let subject: CurrentValueSubject<NWPath, Never>
    private var subscriber: AnyCancellable?
    private let queue = DispatchQueue(label: "Monitor")
    
    init() {
        monitor = NWPathMonitor()
        let currentPath = monitor.currentPath
        path = currentPath
        subject = CurrentValueSubject<NWPath, Never>(currentPath)
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.path = path
                self?.subject.send(path)
            }
        }
        monitor.start(queue: queue)
    }
    
    func cleanup() {
        monitor.cancel()
        subject.send(completion: .finished)
    }
    
    private func makePublisher() -> AnyPublisher<NWPath, Never> {
        return subject.eraseToAnyPublisher()
    }
}
