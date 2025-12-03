//
//  Data.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 21.11.2025.
//

import UIKit

extension Data {
    var imageDate: String? {
        if let source = CGImageSourceCreateWithData(self as CFData, nil),
           let metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
           let exif = metadata[kCGImagePropertyExifDictionary] as? [CFString: Any],
           let dateString = exif[kCGImagePropertyExifDateTimeOriginal] as? String
        {
            return dateString
        } else {
            return nil
        }
    }
}

extension DateComponents {
    init(string: String) {
        self = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: Date(string: string))
    }
    
    var stringMonthes: [Int: String] {
        [
            1: "January",
            2: "February",
            3: "March",
            4: "April",
            5: "May",
            6: "June",
            7: "July",
            8: "August",
            9: "September",
            10: "October",
            11: "November",
            12: "December"
        ]
    }
    
    var stringMonthesShort: [Int: String] {
        [
            1: "Jan",
            2: "Feb",
            3: "Mar",
            4: "Apr",
            5: "May",
            6: "June",
            7: "Jul",
            8: "Aug",
            9: "Sept",
            10: "Oct",
            11: "Nov",
            12: "Dec"
        ]
    }
    
    var stringDate: String {
        "\(stringMonthesShort[month ?? 0] ?? "") \(day ?? 0) , \(year ?? 0)"
    }
    
    var stringTime: String {
        "\(hour ?? 0): \(minute ?? 0)"
    }
}

extension Int {
    var megabytes: Double {
        Double(self) / (1024 * 1024)
    }
    
    var megabytesString: String {
        .init(format: "%.2f", megabytes)
    }
}

extension CVarArg {
    var formated: String {
        .init(format: "%.2f", self)
    }
}

extension String {
    var numbers: Int? {
        Int(self.filter({$0.isNumber}))
    }
}
