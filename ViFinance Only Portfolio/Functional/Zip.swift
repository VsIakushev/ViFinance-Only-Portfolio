//
//  Zip.swift
//  ViFinance Only Portfolio
//
//  Created by Vitaliy Iakushev on 22.01.2023.
//  Copyright © 2023 Vitaliy Iakushev. All rights reserved.
//

import Foundation

func zip<A, B>(_ a: A?, _ b: B?) -> (A, B)? {
    guard let a, let b else { return  nil }
    
    return (a, b)
}

func zip<A, B, C>(_ a: A?, _ b: B?, _ c: C?) -> (A, B, C)? {
    guard let a, let b, let c else { return  nil }
    
    return (a, b, c)
}

func zip<A, B, C, D>(_ a: A?, _ b: B?, _ c: C?, _ d: D?) -> (A, B, C, D)? {
    guard let a, let b, let c, let d else { return  nil }
    
    return (a, b, c, d)
}

func zip<A, B, C, D, E>(_ a: A?, _ b: B?, _ c: C?, _ d: D?, _ e: E?) -> (A, B, C, D, E)? {
    guard let a, let b, let c, let d, let e else { return  nil }
    
    return (a, b, c, d, e)
}
