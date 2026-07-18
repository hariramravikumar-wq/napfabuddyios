import SwiftUI

struct StudentQRCodeView: View {

    let studentID: String
    let studentName: String
    let studentClass: String

    var body: some View {

        VStack(spacing: 25) {

            Image(uiImage: QRCodeGenerator.generate(from: studentID))
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 250)

            Text(studentName)
                .font(.title)
                .bold()

            Text(studentClass)
                .foregroundColor(.secondary)

            Text(studentID)
                .font(.caption)
                .foregroundColor(.gray)

            Spacer()
        }
        .padding()
        .navigationTitle("Student QR")
    }
}
