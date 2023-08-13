//
//  TaskGroup.swift
//  ConcurrencyStudy
//
//  Created by 235 on 2023/08/13.
//


import SwiftUI
class TaskGroupManager {
    func fetchImage(urlString: String) async throws -> UIImage {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url,delegate: nil)
            if let image = UIImage(data: data) {
                return image
            } else{
                throw URLError(.badURL)
            }
        } catch {
            throw error
        }
    }
    func fetchImageWithAsyncLet() async throws -> [UIImage] {
        async let fetchImage1 = fetchImage(urlString: "https://picsum.photos/300")
        async let fetchImage2 = fetchImage(urlString: "https://picsum.photos/300")
        async let fetchImage3 = fetchImage(urlString: "https://picsum.photos/300")
        let (image1,image2,image3) = await (try fetchImage1, try fetchImage2, try fetchImage3)
        return [image1,image2, image3]
    }

    func fetchImagesWithTaskGroup() async throws -> [UIImage] {
        let urlStrings = [
            "https://picsum.photos/300",
            "https://picsum.photos/300",
            "https://picsum.photos/300",
            "https://picsum.photos/300",
            "https://picsum.photos/300",
        ]
        return try await withThrowingTaskGroup(of: UIImage?.self){ group  in
            var images: [UIImage] = []
            images.reserveCapacity(urlStrings.count)
            for urlString in urlStrings {
                group.addTask {
                    try? await self.fetchImage(urlString: urlString)
                }
            }
//            for try await image in group {
//                if let image = image {
//                    images.append(image)
//                }
//            }
            while let image = try await group.next() {
                if let image = image {
                   images.append(image)
                }
             }
            return images
        }
    }
}

class TaskGroupViewModel: ObservableObject {
    @Published var images: [UIImage] = []
    let manager = TaskGroupManager()
    func getImage() async {
        if let images = try? await manager.fetchImagesWithTaskGroup() {
            self.images.append(contentsOf: images)
        }
    }
}
struct TaskGroup: View {
    @StateObject private var vm = TaskGroupViewModel()
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(vm.images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 160)
                    }
                }
            }
        }
        .task {
            await vm.getImage()
        }
        .navigationTitle("TASKGROUP")
    }
}
struct TaskGroup_Previews: PreviewProvider {
    static var previews: some View {
        TaskGroup()
    }
}
