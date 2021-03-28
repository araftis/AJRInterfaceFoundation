
import Foundation

public extension Scanner {
    
//    func scanString(_ string: String) -> String? {
//        var temp : NSString? = nil
//        return scanString(string, into: &temp) ? (temp! as String) : nil
//    }

    func scanDouble() -> Double? {
        return scanDouble(representation: .decimal)
    }
    
}

public extension CGPoint {

    init?(string: String) {
        let scanner = Scanner(string: string)
        
        if scanner.scanString("{") != nil,
            let x = scanner.scanDouble(),
            scanner.scanString(",") != nil,
            let y = scanner.scanDouble(),
            scanner.scanString("}") != nil {
            self.init(x: x, y: y)
        } else {
            return nil
        }
    }
    
}

public extension CGSize {
    
    func scale(to newSize: CGSize, by method: AJRSizeScaling) -> CGSize {
        return AJRScaleSize(self, newSize, method)
    }
    
    func scale(by scale: CGFloat) -> CGSize {
        return AJRSizeByScaling(self, scale)
    }
    
    init?(string: String) {
        let scanner = Scanner(string: string)
        
        if scanner.scanString("{") != nil,
            let width = scanner.scanDouble(),
            scanner.scanString(",") != nil,
            let height = scanner.scanDouble(),
            scanner.scanString("}") != nil {
            self.init(width: width, height: height)
        } else {
            return nil
        }
    }
    
}

public extension CGRect {

    func inset(with insets: AJREdgeInsets, flipped: Bool = false) -> CGRect {
        return AJRInsetRect(self, insets, flipped)
    }
    
    func byCentering(in containingRect: CGRect, method: AJRRectCentering) -> CGRect {
        return AJRRectByCenteringInRect(self, containingRect, method)
    }
    
    init?(string: String) {
        let scanner = Scanner(string: string)
        
        if scanner.scanString("{") != nil,
            scanner.scanString("{") != nil,
            let x = scanner.scanDouble(),
            scanner.scanString(",") != nil,
            let y = scanner.scanDouble(),
            scanner.scanString("}") != nil,
            scanner.scanString(",") != nil,
            scanner.scanString("{") != nil,
            let width = scanner.scanDouble(),
            scanner.scanString(",") != nil,
            let height = scanner.scanDouble(),
            scanner.scanString("}") != nil,
            scanner.scanString("}") != nil {
            self.init(x: x, y: y, width: width, height: height)
        } else {
            return nil
        }
    }
}

extension CGSize : AJRUserDefaultProvider {
    
    public static func userDefault(forKey key: String, from userDefaults: UserDefaults) -> CGSize? {
        if let rawSize = userDefaults.string(forKey: key) {
            return CGSize(string: rawSize)
        }
        return nil
    }
    
    public static func setUserDefault(_ value: CGSize?, forKey key: String, into userDefaults: UserDefaults) {
        if let value = value {
            userDefaults.set("{\(value.width), \(value.height)}", forKey: key)
        } else {
            userDefaults.set(nil, forKey: key)
        }
    }
    
}

extension CGPoint : AJRUserDefaultProvider {
    
    public static func userDefault(forKey key: String, from userDefaults: UserDefaults) -> CGPoint? {
        if let rawPoint = userDefaults.string(forKey: key) {
            return CGPoint(string: rawPoint)
        }
        return nil
    }
    
    public static func setUserDefault(_ value: CGPoint?, forKey key: String, into userDefaults: UserDefaults) {
        if let value = value {
            userDefaults.set("{\(value.x), \(value.y)}", forKey: key)
        } else {
            userDefaults.set(nil, forKey: key)
        }
    }
    
}

extension CGRect : AJRUserDefaultProvider {
    
    public static func userDefault(forKey key: String, from userDefaults: UserDefaults) -> CGRect? {
        if let rawRect = userDefaults.string(forKey: key) {
            return CGRect(string: rawRect)
        }
        return nil
    }
    
    public static func setUserDefault(_ value: CGRect?, forKey key: String, into userDefaults: UserDefaults) {
        if let value = value {
            userDefaults.set("{{\(value.origin.x), \(value.origin.y)}, {\(value.size.width), \(value.size.height)}}", forKey: key)
        } else {
            userDefaults.set(nil, forKey: key)
        }
    }
    
}


