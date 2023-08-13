//
//  DownloadImageAsyncImageLoader.swift
//  ConcurrencyStudy
//
//  Created by 235 on 2023/08/08.
//

import SwiftUI
import Combine

class AsyncAwaitBootCampViewModel: ObservableObject {
    @Published var dateArray: [String] = []
    func addAuthor1() async {
        let author1 = "Author1 : \(Thread.current)"
        self.dateArray.append(author1)
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        let author2 = "Author2 : \(Thread.current)"
        self.dateArray.append(author2)
        try? await doSomething()

        await MainActor.run(body: {
            let author4 = "Author3: \(Thread.current)"
            self.dateArray.append(author4)
        })
    }

    func doSomething() async throws {
        let author3 = "something1 : \(Thread.current)"
        self.dateArray.append(author3)
    }
    
}
struct AsyncAwait : View{
    @StateObject private var vm = AsyncAwaitBootCampViewModel()
    var body: some View {
        List{
            ForEach(vm.dateArray, id: \.self) { data in
                Text(data)
            }
        }
        .onAppear {
            Task {
                await vm.addAuthor1()
            }
        }
    }
}

struct AsyncAwait_Previews: PreviewProvider {
    static var previews: some View {
        AsyncAwait()
    }
}
