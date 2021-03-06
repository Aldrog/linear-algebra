# Copyright 2015 UniCredit S.p.A.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

template makeVectorPrivate(N, f, result: expr) =
  new result
  for i in 0 .. < N:
    result[i] = f(i)

proc makeVector*(N: static[int], f: proc (i: int): float64): Vector64[N] = makeVectorPrivate(N, f, result)

proc makeVector*(N: static[int], f: proc (i: int): float32): Vector32[N] = makeVectorPrivate(N, f, result)

proc randomVector*(N: static[int], max: float64 = 1): Vector64[N] =
  makeVector(N, proc(i: int): float64 = random(max))

proc randomVector*(N: static[int], max: float32): Vector32[N] =
  makeVector(N, proc(i: int): float32 = random(max).float32)

template constantVectorPrivate(N, x, result: expr) =
  new result
  for i in 0 .. < N:
    result[i] = x

proc constantVector*(N: static[int], x: float64): Vector64[N] = constantVectorPrivate(N, x, result)

proc constantVector*(N: static[int], x: float32): Vector32[N] = constantVectorPrivate(N, x, result)

proc zeros*(N: static[int]): Vector64[N] = constantVector(N, 0'f64)

proc zeros*(N: static[int], A: typedesc): auto =
  when A is float64: constantVector(N, 0'f64)
  else:
    when A is float32: constantVector(N, 0'f32)

proc ones*(N: static[int]): Vector64[N] = constantVector(N, 1'f64)

proc ones*(N: static[int], A: typedesc): auto =
  when A is float64: constantVector(N, 1'f64)
  else:
    when A is float32: constantVector(N, 1'f32)

type Array[N: static[int], A] = array[N, A]

proc vector*[N: static[int]](xs: Array[N, float64]): Vector64[N] =
  new result
  for i in 0 .. < N:
    result[i] = xs[i]

proc vector*[N: static[int]](xs: Array[N, float32], A: typedesc): Vector32[N] =
  when A is float32:
    new result
    for i in 0 .. < N:
      result[i] = xs[i]

proc vector32*[N: static[int]](xs: Array[N, float32]): Vector32[N] =
  new result
  for i in 0 .. < N:
    result[i] = xs[i]

proc dvector*(N: static[int], xs: seq[float64]): Vector64[N] =
  makeVector(N, proc(i: int): float64 = xs[i])

proc dvector*(N: static[int], xs: seq[float32]): Vector32[N] =
  makeVector(N, proc(i: int): float32 = xs[i])

template makeMatrixPrivate(M, N, f, order, result: expr, A: typedesc) =
  new result.data
  result.order = order
  if order == colMajor:
    var data = cast[ref array[N, array[M, A]]](result.data)
    for i in 0 .. < M:
      for j in 0 .. < N:
        data[j][i] = f(i, j)
  else:
    var data = cast[ref array[M, array[N, A]]](result.data)
    for i in 0 .. < M:
      for j in 0 .. < N:
        data[i][j] = f(i, j)

proc makeMatrix*(M, N: static[int], f: proc (i, j: int): float64, order: OrderType = colMajor): Matrix64[M, N] =
  makeMatrixPrivate(M, N, f, order, result, float64)

proc makeMatrix*(M, N: static[int], f: proc (i, j: int): float32, order: OrderType = colMajor): Matrix32[M, N] =
  makeMatrixPrivate(M, N, f, order, result, float32)

proc randomMatrix*(M, N: static[int], max: float64 = 1, order: OrderType = colMajor): Matrix64[M, N] =
  makeMatrix(M, N, proc(i, j: int): float64 = random(max), order)

proc randomMatrix*(M, N: static[int], max: float32, order: OrderType = colMajor): Matrix32[M, N] =
  makeMatrix(M, N, proc(i, j: int): float32 = random(max).float32, order)

template constantMatrixPrivate(M, N, x, order, result: expr, A: typedesc) =
  new result.data
  result.order = order
  if order == colMajor:
    var data = cast[ref array[N, array[M, A]]](result.data)
    for i in 0 .. < M:
      for j in 0 .. < N:
        data[j][i] = x
  else:
    var data = cast[ref array[M, array[N, A]]](result.data)
    for i in 0 .. < M:
      for j in 0 .. < N:
        data[i][j] = x

proc constantMatrix*(M, N: static[int], x: float64, order: OrderType = colMajor): Matrix64[M, N] =
  constantMatrixPrivate(M, N, x, order, result, float64)

proc constantMatrix*(M, N: static[int], x: float32, order: OrderType = colMajor): Matrix32[M, N] =
  constantMatrixPrivate(M, N, x, order, result, float32)

proc zeros*(M, N: static[int], order: OrderType = colMajor): Matrix64[M, N] = constantMatrix(M, N, 0'f64, order)

proc zeros*(M, N: static[int], A: typedesc, order: OrderType = colMajor): auto =
  when A is float64: constantMatrix(M, N, 0'f64, order)
  else:
    when A is float32: constantMatrix(M, N, 0'f32, order)

proc ones*(M, N: static[int], order: OrderType = colMajor): Matrix64[M, N] = constantMatrix(M, N, 1'f64, order)

proc ones*(M, N: static[int], A: typedesc, order: OrderType = colMajor): auto =
  when A is float64: constantMatrix(M, N, 1'f64, order)
  else:
    when A is float32: constantMatrix(M, N, 1'f32, order)

template eyePrivate(N, order, result: expr, A: typedesc) =
  new result.data
  result.order = order
  var data = cast[ref array[N, array[N, A]]](result.data)
  for i in 0 .. < N:
    for j in 0 .. < N:
      data[i][j] = if i == j: 1 else: 0


proc eye32(N: static[int], order: OrderType): Matrix32[N, N] = eyePrivate(N, order, result, float32)

proc eye64(N: static[int], order: OrderType): Matrix64[N, N] = eyePrivate(N, order, result, float64)

proc eye*(N: static[int], order: OrderType = colMajor): Matrix64[N, N] = eye64(N, order)

proc eye*(N: static[int], A: typedesc, order: OrderType = colMajor): auto =
  when A is float64: eye64(N, order)
  else:
    when A is float32: eye32(N, order)

proc dmatrix*(M, N: static[int], xs: seq[seq[float64]], order: OrderType = colMajor): Matrix64[M, N] =
  makeMatrix(M, N, proc(i, j: int): float64 = xs[i][j], order)

proc dmatrix*(M, N: static[int], xs: seq[seq[float32]], order: OrderType = colMajor): Matrix32[M, N] =
  makeMatrix(M, N, proc(i, j: int): float32 = xs[i][j], order)