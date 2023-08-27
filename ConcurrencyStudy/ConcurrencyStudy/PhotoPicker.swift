//
//  PhotoPicker.swift
//  ConcurrencyStudy
//
//  Created by 235 on 2023/08/27.
//

import SwiftUI
import PhotosUI

@MainActor
final class photoViewModel: ObservableObject {
    @Published private(set) var selectedImage: Image? = nil
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet{
            setImage(from: imageSelection)
        }
    }

    @Published private(set) var selectedImages: [Image] = []
    @Published var imageSelections: [PhotosPickerItem] = [] {
        didSet{
            setImages(from: imageSelections)
        }
    }
    private func setImage(from selection: PhotosPickerItem?) {
        guard let selection else {return}
        Task {
//            if let data = try? await selection.loadTransferable(type: Image.self){
//                selectedImage = data
//            }
            do {
                let image = try await selection.loadTransferable(type: Image.self)
                guard let image else {throw URLError(.badServerResponse)}
            } catch {
                print(error)
            }
        }
    }
    private func setImages(from selections: [PhotosPickerItem]) {
        Task {
            do{
                var images : [Image] = []
                for selection in selections {
                    if let image = try? await selection.loadTransferable(type: Image.self) {
                        images.append(image)
                    }
                }
                    self.selectedImages = images

            } catch{
                print(error)
            }
        }
    }
}
struct PhotoPickerView: View {
    @StateObject private var viewModel = photoViewModel()
    var body: some View {
        VStack(spacing: 40) {
            if let image = viewModel.selectedImage {
                image
                    .resizable()
                    .scaledToFill()
                    .frame( width: 400, height: 200)
                    .cornerRadius(10)
            }
            PhotosPicker(selection: $viewModel.imageSelection) {
                Text("click the image")
            }
            if !viewModel.selectedImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(0..<viewModel.selectedImages.count) {
                            imageindex in
                            viewModel.selectedImages[imageindex]
                                .resizable()
                                .scaledToFill()
                                .frame( width: 40, height: 40)
                                .cornerRadius(10)
                        }
                    }
                }
            }
            PhotosPicker(selection: $viewModel.imageSelections, matching: .images) {
                Text("click the imagessss").foregroundColor(.red)
            }
        }
    }
}
struct PhotoPicker_Previews: PreviewProvider {
    static var previews: some View {
        PhotoPickerView()
    }
}
