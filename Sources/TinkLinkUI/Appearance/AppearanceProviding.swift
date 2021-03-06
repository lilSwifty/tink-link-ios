import UIKit

/// A type that can provide colors and fonts for Tink views.
public protocol AppearanceProviding {
    /// Color provider
    var colors: ColorProviding { get }
    /// Font provider
    var fonts: FontProviding { get }
}

/// An appearance provider that can provide colors and fonts for Tink views.
public struct AppearanceProvider: AppearanceProviding {
    /// Color provider
    public let colors: ColorProviding
    /// Font provider
    public let fonts: FontProviding

    /// Creates a customized Appearance with specific providers, if no value is passed, the default provider will be used.
    public init(
        colors: ColorProvider? = nil,
        fonts: FontProvider? = nil
    ) {
        self.colors = colors ?? ColorProvider()
        self.fonts = fonts ?? FontProvider()
    }
}
