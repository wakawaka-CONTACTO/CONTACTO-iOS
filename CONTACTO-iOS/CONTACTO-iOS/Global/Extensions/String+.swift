//
//  String+.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/13/24.
//

import Foundation

extension String {
    /// emoji 제외 메소드
    func hasCharacters() -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: "^[0-9a-zA-Z가-힣ㄱ-ㅎㅏ-ㅣ`~!@#$%^&*()\\-_=+\\[{\\]}\\\\|;:'\",<.>/?\\s]$", options: .caseInsensitive)
            if let _ = regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSMakeRange(0, self.count)) {
                return true
            }
        }catch {
            return false
        }
        return false
    }
    
    /// 공백만 있으면 true
    func isOnlyWhitespace() -> Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// 2024-11-18T00:32:21.750245 -> 00:32
    func toTimeIn24HourFormat() -> String? {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withFullDate, .withTime, .withColonSeparatorInTime]
        
        guard let date = isoFormatter.date(from: self) else {
            return nil
        }
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        return timeFormatter.string(from: date)
    }
    
    /// 두 날짜 비교 후 다르다면 true
    func isDateDifferent(from otherDateString: String) -> Bool? {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withFullDate, .withTime, .withColonSeparatorInTime]
        
        guard let date1 = isoFormatter.date(from: self) else {
            return nil
        }
        
        guard let date2 = isoFormatter.date(from: otherDateString) else {
            return nil
        }
        
        let calendar = Calendar.current
        let isDifferent = !calendar.isDate(date1, inSameDayAs: date2)
        
        return isDifferent
    }
    
    /// NOV.19.2024
    func toCustomDateFormat() -> String? {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withFullDate, .withTime, .withColonSeparatorInTime]
        
        guard let date = isoFormatter.date(from: self) else {
            return nil
        }
        
        let customFormatter = DateFormatter()
        customFormatter.dateFormat = "MMM.dd.yyyy"
        customFormatter.locale = Locale(identifier: "en_US")
        
        return customFormatter.string(from: date).uppercased()
    }
    
    func isValidEmail() -> Bool {
          let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
          let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
          return emailTest.evaluate(with: self)
    }
}
