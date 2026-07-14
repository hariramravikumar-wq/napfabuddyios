//
//  QRScannerView.swift
//  UI draft
//
//  Created by Rayson Ng on 13/7/26.
//

import SwiftUI
import Vision
import VisionKit

@available(iOS 16.0, *)
struct QRScannerView: UIViewControllerRepresentable {

    var completion: (String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> DataScannerViewController {

        let scanner = DataScannerViewController(
            recognizedDataTypes: [
                .barcode(symbologies: [.qr])
            ],
            qualityLevel: .accurate,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: true,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )

        scanner.delegate = context.coordinator

        do {
            try scanner.startScanning()
        } catch {
            print("❌ Failed to start scanner: \(error.localizedDescription)")
        }

        return scanner
    }

    func updateUIViewController(
        _ uiViewController: DataScannerViewController,
        context: Context
    ) {
        // Nothing to update
    }

    class Coordinator: NSObject, DataScannerViewControllerDelegate {

        let parent: QRScannerView

        init(_ parent: QRScannerView) {
            self.parent = parent
        }

        func dataScanner(
            _ dataScanner: DataScannerViewController,
            didAdd addedItems: [RecognizedItem],
            allItems: [RecognizedItem]
        ) {

            guard let firstItem = addedItems.first else { return }

            switch firstItem {

            case .barcode(let barcode):

                guard let value = barcode.payloadStringValue else { return }

                parent.completion(value)

                dataScanner.dismiss(animated: true)

            default:
                break
            }
        }

        func dataScanner(
            _ dataScanner: DataScannerViewController,
            didTapOn item: RecognizedItem
        ) {

            switch item {

            case .barcode(let barcode):

                guard let value = barcode.payloadStringValue else { return }

                parent.completion(value)

                dataScanner.dismiss(animated: true)

            default:
                break
            }
        }
    }
}
