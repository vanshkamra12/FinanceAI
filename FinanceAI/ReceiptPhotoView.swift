import SwiftUI
import PhotosUI
import CoreData

struct ReceiptPhotoView: View {
    let transaction: Transaction
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var receiptImage: UIImage?
    @State private var showingCamera = false
    @State private var receiptPhotos: [Receipt] = []
    @State private var isLoading = false
    @State private var showingFullScreenImage: Receipt?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                headerSection
                
                ScrollView {
                    VStack(spacing: 20) {
                        transactionInfoSection
                        addPhotoSection
                        existingPhotosSection
                    }
                    .padding(20)
                }
            }
            .background(themeManager.backgroundColor)
            .navigationBarHidden(true)
            .onAppear {
                loadReceiptPhotos()
            }
            .onChange(of: selectedPhoto) { newItem in
                Task {
                    if let newItem = newItem {
                        await loadSelectedPhoto(item: newItem)
                    }
                }
            }
            .sheet(isPresented: $showingCamera) {
                CameraView { image in
                    saveReceiptPhoto(image: image)
                }
            }
            .sheet(item: $showingFullScreenImage) { receipt in
                FullScreenImageView(receipt: receipt)
                    .environmentObject(themeManager)
            }
        }
    }
    
    private var headerSection: some View {
        HStack {
            Button("Cancel") {
                dismiss()
            }
            .foregroundColor(themeManager.textSecondary)
            
            Spacer()
            
            VStack {
                Text("Receipt Photos")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(themeManager.textPrimary)
                
                Text("\(receiptPhotos.count) photos")
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
            }
            
            Spacer()
            
            Button("Done") {
                dismiss()
            }
            .foregroundColor(themeManager.primaryColor)
            .fontWeight(.semibold)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    private var transactionInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Transaction Details")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)
            
            HStack {
                CategoryIcon(category: transaction.category ?? "Other", size: 20)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(transaction.category ?? "Uncategorized")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(themeManager.textPrimary)
                    
                    if let note = transaction.note, !note.isEmpty {
                        Text(note)
                            .font(.caption)
                            .foregroundColor(themeManager.textSecondary)
                    }
                    
                    Text(formatDate(transaction.date))
                        .font(.caption)
                        .foregroundColor(themeManager.textSecondary)
                }
                
                Spacer()
                
                Text(transaction.isExpense
                     ? "-$\(transaction.amount?.stringValue ?? "0")"
                     : "+$\(transaction.amount?.stringValue ?? "0")")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(transaction.isExpense ? themeManager.errorColor : themeManager.successColor)
            }
        }
        .padding(20)
        .background(themeManager.cardColor)
        .cornerRadius(16)
    }
    
    private var addPhotoSection: some View {
        VStack(spacing: 16) {
            Text("Add Receipt Photo")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)
            
            if isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Processing photo...")
                        .font(.caption)
                        .foregroundColor(themeManager.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(themeManager.backgroundColor)
                .cornerRadius(12)
            } else {
                HStack(spacing: 16) {
                    // Camera button
                    Button {
                        showingCamera = true
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                            
                            Text("Camera")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [themeManager.primaryColor, themeManager.accentColor]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    
                    // Photo library button
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        VStack(spacing: 8) {
                            Image(systemName: "photo.fill")
                                .font(.title2)
                                .foregroundColor(themeManager.primaryColor)
                            
                            Text("Gallery")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(themeManager.primaryColor)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(themeManager.cardColor)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(themeManager.primaryColor, lineWidth: 2)
                        )
                    }
                }
            }
        }
        .padding(20)
        .background(themeManager.cardColor)
        .cornerRadius(16)
    }
    
    private var existingPhotosSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Receipt Photos (\(receiptPhotos.count))")
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)
            
            if receiptPhotos.isEmpty {
                emptyPhotosView
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                    ForEach(receiptPhotos, id: \.id) { receipt in
                        receiptPhotoCard(receipt: receipt)
                    }
                }
            }
        }
        .padding(20)
        .background(themeManager.cardColor)
        .cornerRadius(16)
    }
    
    private var emptyPhotosView: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo.badge.plus")
                .font(.system(size: 40))
                .foregroundColor(themeManager.textSecondary)
            
            Text("No photos yet")
                .font(.subheadline)
                .foregroundColor(themeManager.textPrimary)
            
            Text("Take photos of your receipts to keep better financial records")
                .font(.caption)
                .foregroundColor(themeManager.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(themeManager.backgroundColor)
        .cornerRadius(12)
    }
    
    private func receiptPhotoCard(receipt: Receipt) -> some View {
        VStack(spacing: 8) {
            if let imageData = receipt.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 140)
                    .clipped()
                    .cornerRadius(8)
                    .onTapGesture {
                        showingFullScreenImage = receipt
                    }
            } else {
                Rectangle()
                    .fill(themeManager.textSecondary.opacity(0.3))
                    .frame(height: 140)
                    .cornerRadius(8)
                    .overlay(
                        VStack(spacing: 4) {
                            Image(systemName: "photo")
                                .font(.title2)
                                .foregroundColor(themeManager.textSecondary)
                            Text("Failed to load")
                                .font(.caption)
                                .foregroundColor(themeManager.textSecondary)
                        }
                    )
            }
            
            HStack {
                Text(formatDate(receipt.createdDate))
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
                
                Spacer()
                
                Button {
                    deleteReceipt(receipt)
                } label: {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundColor(themeManager.errorColor)
                }
            }
        }
        .padding(8)
        .background(themeManager.backgroundColor)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Photo Management Functions
    
    private func loadSelectedPhoto(item: PhotosPickerItem) async {
        isLoading = true
        
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                
                // Compress image to reasonable size
                let compressedImage = compressImage(image)
                
                await MainActor.run {
                    saveReceiptPhoto(image: compressedImage)
                    isLoading = false
                }
            }
        } catch {
            await MainActor.run {
                print("Error loading photo: \(error)")
                isLoading = false
            }
        }
    }
    
    private func compressImage(_ image: UIImage) -> UIImage {
        let maxSize: CGFloat = 1024 // Max width/height
        let compressionQuality: CGFloat = 0.7
        
        // Resize if needed
        var resizedImage = image
        if image.size.width > maxSize || image.size.height > maxSize {
            let ratio = min(maxSize / image.size.width, maxSize / image.size.height)
            let newSize = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)
            
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: CGRect(origin: .zero, size: newSize))
            resizedImage = UIGraphicsGetImageFromCurrentImageContext() ?? image
            UIGraphicsEndImageContext()
        }
        
        // Compress
        if let compressedData = resizedImage.jpegData(compressionQuality: compressionQuality),
           let compressedImage = UIImage(data: compressedData) {
            return compressedImage
        }
        
        return resizedImage
    }
    
    // ✅ UPDATED: Using Core Data relationships instead of transactionId
    private func saveReceiptPhoto(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to data")
            return
        }
        
        let receipt = Receipt(context: viewContext)
        receipt.id = UUID()
        receipt.imageData = imageData
        receipt.createdDate = Date()
        
        // ✅ NEW: Use relationship instead of transactionId
        receipt.transaction = transaction
        
        do {
            try viewContext.save()
            print("✅ Receipt saved successfully with relationship")
            print("📄 Transaction now has \(transaction.receipts?.count ?? 0) receipts")
            loadReceiptPhotos() // Reload to show new photo
        } catch {
            print("❌ Error saving receipt: \(error)")
        }
    }
    
    // ✅ UPDATED: Using Core Data relationships instead of NSFetchRequest
    private func loadReceiptPhotos() {
        // ✅ NEW: Use relationship to get receipts directly
        if let receipts = transaction.receipts as? Set<Receipt> {
            receiptPhotos = receipts.sorted {
                ($0.createdDate ?? Date()) > ($1.createdDate ?? Date())
            }
            print("✅ Loaded \(receiptPhotos.count) receipts using relationship")
        } else {
            receiptPhotos = []
            print("ℹ️ No receipts found for this transaction")
        }
    }
    
    private func deleteReceipt(_ receipt: Receipt) {
        // ✅ Relationship handles unlinking automatically
        viewContext.delete(receipt)
        
        do {
            try viewContext.save()
            loadReceiptPhotos() // Reload to reflect deletion
            print("✅ Receipt deleted successfully")
        } catch {
            print("❌ Error deleting receipt: \(error)")
        }
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Full Screen Image View

struct FullScreenImageView: View {
    let receipt: Receipt
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if let imageData = receipt.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipped()
                } else {
                    Text("Failed to load image")
                        .foregroundColor(.white)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - Camera View

struct CameraView: UIViewControllerRepresentable {
    let onImageCaptured: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        picker.cameraCaptureMode = .photo // Better for file size
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImageCaptured(image)
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

struct ReceiptPhotoView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let sampleTransaction = Transaction(context: context)
        sampleTransaction.id = UUID()
        sampleTransaction.amount = 25.50
        sampleTransaction.category = "Food"
        sampleTransaction.date = Date()
        sampleTransaction.isExpense = true
        
        return ReceiptPhotoView(transaction: sampleTransaction)
            .environment(\.managedObjectContext, context)
            .environmentObject(ThemeManager())
    }
}

