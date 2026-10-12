import SwiftUI
import UIKit

struct DetPassGeneratorView: View {
    @State private var secret = ""
    @State private var site = ""
    @State private var password: String?
    @State private var outputText: String?
    @State private var statusText = "Enter Details to Generate Password"
    @State private var copied = false
    @FocusState private var focusedField: Field?

    private enum Field {
        case secret
        case site
    }

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            ZStack {
                DetPassPulsingOutline()
                    .allowsHitTesting(false)

                VStack(spacing: 10) {
                    HStack(alignment: .top, spacing: 10) {
                        VStack(spacing: 10) {
                            SecureField("Your secret", text: $secret)
                                .focused($focusedField, equals: .secret)
                                .submitLabel(.next)
                                .onSubmit { focusedField = .site }
                                .detPassInputStyle()

                            TextField("example.com", text: $site)
                                .keyboardType(.URL)
                                .focused($focusedField, equals: .site)
                                .submitLabel(.go)
                                .onSubmit(generatePassword)
                                .detPassInputStyle()
                        }

                        Button(action: generatePassword) {
                            ZStack {
                                if password == nil {
                                    Text("Generate")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(.white)
                                        .minimumScaleFactor(0.75)
                                        .lineLimit(1)
                                } else {
                                    Image("Kitty")
                                        .resizable()
                                        .scaledToFit()
                                        .padding(7)
                                }
                            }
                            .frame(width: 98, height: 98)
                            .background(DetPassTheme.blue)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .shadow(color: DetPassTheme.shadow, radius: 0, x: 3, y: 3)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Generate password")
                    }

                    if let outputText {
                        Text(outputText)
                            .font(.system(size: 24, weight: .regular, design: .monospaced))
                            .lineLimit(1)
                            .minimumScaleFactor(0.65)
                            .frame(maxWidth: .infinity, minHeight: 20)
                            .padding(8)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .shadow(color: DetPassTheme.shadow, radius: 0, x: 3, y: 3)
                            .contentShape(Rectangle())
                            .onTapGesture(perform: copyPassword)
                            .accessibilityLabel(password == nil ? "Password generation failed" : "Generated password")
                    }

                    Text(statusText)
                        .font(.system(size: 12))
                        .foregroundStyle(copied ? DetPassTheme.blue : DetPassTheme.textMuted)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .frame(maxWidth: .infinity)
                }
                .padding(12)
                .background(DetPassTheme.cardGradient)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .frame(maxWidth: 340)
            .padding(.horizontal, 18)
        }
        .onOpenURL { url in
            guard url.scheme == "detpass" else { return }
            focusedField = .secret
        }
    }

    private func generatePassword() {
        do {
            let cleanSite = site.trimmingCharacters(in: .whitespacesAndNewlines)
            let derived = try DetPassGenerator.derivePassword(secret: secret, site: cleanSite)
            password = derived
            outputText = derived
            statusText = "CLICK TO COPY"
            copied = false
            focusedField = nil
        } catch {
            password = nil
            outputText = ":("
            statusText = error.localizedDescription
            copied = false
        }
    }

    private func copyPassword() {
        guard let password else { return }
        UIPasteboard.general.string = password
        statusText = "COPIED"
        copied = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            guard copied else { return }
            statusText = "CLICK TO COPY"
            copied = false
        }
    }
}
