//
//  PerspectiveTransformSpecHelper.swift
//  PerspectiveTransform
//
//  Created by Paul Zabelin on 2/28/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import GameKit
import Nimble

@testable import PerspectiveTransform

func beCloseTo(_ expectedValue: Matrix3x3Type, within delta: Double = 0.00001) -> Predicate<Matrix3x3Type> {
    return Predicate<Matrix3x3Type> { actualExpression in
        let actualValue = try! actualExpression.evaluate()!
        return PredicateResult(
            bool: simd_almost_equal_elements(actualValue, expectedValue, ScalarType(delta)),
            message: ExpectationMessage.expectedActualValueTo("be close to \(expectedValue)")
        )
    }
}

func beCloseTo(_ expectedValue: Vector3Type, within delta: Double = 0.00001) -> Predicate<Vector3Type> {
    return Predicate<Vector3Type> { actualExpression in
        let actualValue = try! actualExpression.evaluate()!
        let isClose = (abs(actualValue.x - expectedValue.x) < delta) &&
            (abs(actualValue.y - expectedValue.y) < delta) &&
            (abs(actualValue.z - expectedValue.z) < delta)
        return PredicateResult(
            bool: isClose,
            message: ExpectationMessage.expectedActualValueTo("be close to \(expectedValue)")
        )
    }
}

public func ≈(lhs: Expectation<Matrix3x3Type>, rhs: Matrix3x3Type) {
    lhs.to(beCloseTo(rhs))
}

public func ≈(lhs: Expectation<Matrix3x3Type>, rhs: (expected: Matrix3x3Type, delta: Double)) {
    lhs.to(beCloseTo(rhs.expected, within: rhs.delta))
}

public func ≈(lhs: Expectation<Vector3Type>, rhs: Vector3Type) {
    lhs.to(beCloseTo(rhs))
}

public func ≈(lhs: Expectation<Vector3Type>, rhs: (expected: Vector3Type, delta: Double)) {
    lhs.to(beCloseTo(rhs.expected, within: rhs.delta))
}

extension Matrix3x3Type {
    init(_ array: [ScalarType]) {
        let rows = 3
        let scalars = rows * rows
        precondition(array.count == scalars, "should have 9 values for 3x3 matrix")
        var rowsOfVectors: [Vector3Type] = []
        for index in stride(from: 0, to: scalars, by: rows) {
            let rowSlice = array[index...index + rows - 1]
            rowsOfVectors.append(Vector3Type(Array(rowSlice)))
        }
        self.init(rows: rowsOfVectors)
    }
}

extension CATransform3D {
    func layerRotation() -> Vector3Type {
        let layer = CALayer()
        layer.transform = self

        var rotate = Vector3Type()
        rotate.x = layer.value(forKeyPath: "transform.rotation.x") as! Double
        rotate.y = layer.value(forKeyPath: "transform.rotation.y") as! Double
        rotate.z = layer.value(forKeyPath: "transform.rotation.z") as! Double
        return rotate
    }
}

extension Vector3Type {
    var dehomogenized: CGPoint {return CGPoint(x: z.isZero ? 0 : x/z, y: z.isZero ? 0 : y/z)}
}

func arrayWith<S>(_ factory: (() -> S)) -> [S] {
    return Array(Vector3Type.indexSlice).map {_ in factory()}
}

extension GKRandomSource {
    func nextVector() -> Vector3Type {
        return Vector3Type(arrayWith(nextDouble))
    }
    func nextMatrix() -> Matrix3x3Type {
        return Matrix3x3Type(arrayWith(nextVector))
    }
}
