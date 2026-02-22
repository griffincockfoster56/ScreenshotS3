import CoreText
import Foundation

enum FontRegistration {
    static func registerBundledFonts() {
        guard let resourcePath = Bundle.main.resourcePath else { return }
        let fontsDir = (resourcePath as NSString).appendingPathComponent("Fonts")

        let fontFiles = ["Inter-Regular", "Inter-Medium", "Inter-SemiBold", "Inter-Bold"]

        for name in fontFiles {
            let path = (fontsDir as NSString).appendingPathComponent("\(name).ttf")
            guard FileManager.default.fileExists(atPath: path) else { continue }
            let url = URL(fileURLWithPath: path)
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}
