//
//  Date+Extension.swift
//  Dosirak
//
//  Created by 권민재 on 11/3/24.
//

import Foundation

extension Date {
    
    /// 메시지 날짜 형식을 반환
    /// - 오늘: `HH:mm`
    /// - 올해: `MM/dd`
    /// - 과거: `yyyy/MM/dd`
    func toMessageFormat() -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        
        if calendar.isDateInToday(self) {
            // 오늘일 경우 시간만 표시
            formatter.dateFormat = "HH:mm"
        } else if calendar.isDate(self, equalTo: Date(), toGranularity: .year) {
            // 올해일 경우 월/일 표시
            formatter.dateFormat = "MM/dd"
        } else {
            // 그 외의 경우 연도/월/일 표시
            formatter.dateFormat = "yyyy/MM/dd"
        }
        
        return formatter.string(from: self)
    }
    
    /// String 날짜 형식을 Date로 변환
    static func from(_ dateString: String, format: String = "yyyy-MM-dd'T'HH:mm:ssZ") -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: dateString)
    }
    
    static func formattedDateString(from serverDateString: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        
        guard let serverDate = dateFormatter.date(from: serverDateString) else {
            return serverDateString
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        
        if calendar.isDateInToday(serverDate) {
            dateFormatter.dateFormat = "HH:mm"
            return dateFormatter.string(from: serverDate)
            
        } else if calendar.isDateInYesterday(serverDate) {
            return "하루 전"
            
        } else {
            
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter.string(from: serverDate)
        }
    }
}

