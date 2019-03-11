//
//  CATransform3D+float3x3.swift
//  Pods
//
//  Created by Paul Zabelin on 2/21/16.
//
//

import simd

extension Vector3Type {
		static let one = Vector3Type(repeating: ScalarType.one)
		static let zero = Vector3Type(repeating: 0)
    static let lastIndex = Vector3Type().indices.endIndex - 1
    static let indexSlice = 0...Vector3Type.lastIndex
    static let indexArray = Array(Vector3Type.indexSlice)
}

extension ScalarType {
    static let one = ScalarType(1)
}

extension Matrix4x3Type {
    static let zeroColumnBeforeLast: Matrix4x3Type =  {
        let identity = Matrix3x3Type(diagonal: Vector3Type.one)
        var columns = Vector3Type.indexArray.map {identity[$0]}
        columns.insert(Vector3Type.zero, at: Vector3Type.lastIndex)
        return Matrix4x3Type(columns)
    }()
}

extension Matrix3x4Type {
    static let zeroRowBeforeLast: Matrix3x4Type =  {
        return Matrix4x3Type.zeroColumnBeforeLast.transpose
    }()

    func insertColumnBeforeLast() -> Matrix4x4Type {
        return self * Matrix4x3Type.zeroColumnBeforeLast
    }
}

extension Matrix3x3Type {
    func insertRowBeforeLast() -> Matrix3x4Type {
        return Matrix3x4Type.zeroRowBeforeLast * self
    }

    func to3d() -> Matrix4x4Type {
        var m4x4 = zNormalized().insertRowBeforeLast().insertColumnBeforeLast()
        m4x4[Vector3Type.lastIndex, Vector3Type.lastIndex] = ScalarType.one
        return m4x4
    }

    private func zNormalized() -> Matrix3x3Type {
        return normalizationFactor * self
    }

    private var normalizationFactor: ScalarType {
        let zScale = self[Vector3Type.lastIndex, Vector3Type.lastIndex]
        assert(zScale.isZero == false, "since we use homogenized vectors, z != 0")
        return ScalarType.one / zScale
    }
}
