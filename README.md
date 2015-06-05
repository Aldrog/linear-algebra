Nim Linear Algebra
==================

The library defines types `Matrix64[M, N]` and `Vector64[N]` and related operations.

In all examples, types are inferred, and are shown just for explanatory purposes.

Initialization
--------------

Here we show a few ways to initialize matrices and vectors. All matrices method accept a parameter to
define whether to store the matrix in row-major or column-major order (default: column-major).

    import linalg

    let
      v1: Vector64[5] = makeVector(5, proc(i: int): float64 = (i * i).float64)
      v2: Vector64[7] = randomVector(7, max = 3) # max is optional, default 1
      v3: Vector64[5] = constant(5, 3.5)
      v4: Vector64[8] = zeros(8)
      v5: Vector64[9] = ones(9)
      m1: Matrix[6, 3] = makeMatrix(6, 3, proc(i, j: int): float64 = (i + j).float64)
      m2: Matrix[2, 8] = randomMatrix(2, 8, max = 1.6) # max is optional, default 1
      m3: Matrix[3, 5] = constant(3, 5, 1.8, order = rowMajor) # order is optional, default colMajor
      m4: Matrix[3, 6] = ones(3, 6)
      m5: Matrix[5, 2] = zeros(5, 2)
      m6: Matrix[7, 7] = eye(7)

Accessors
---------

Vectors can be accessed as expected

    var v6 = randomVector(6)
    v6[4] = 1.2
    echo v6[3]

Same for matrices, where `m[i, j]` denotes the item on row `i` and column `j`, regardless of the matrix order

    var m7 = randomMatrix(3, 7)
    m7[1, 3] = 0.8
    echo m7[2, 2]

Also one can see rows and columns as vectors

    let
      r2: Vector64[7] = m7.row(2)
      c5: Vector64[3] = m7.column(5)

For memory safety, this performs a **copy** of the row or column values, at least for now.

Iterators
---------

One can iterate over vector or matrix elements, as well as over rows and columns

    for x in v6: echo x
    for i, x in v6: echo i, x
    for x in m7: echo x
    for t, x in m7:
      let (i, j) = t
      echo i, j, x
    for row in m7.rows:
      echo row[0]
    for column in m7.columns:
      echo column[1]

Pretty-print
------------

Both vectors and matrix have a pretty-print operation, so one can do

    echo m7

and get something like

    [ [ 0.5024584865674662  0.0798945419892334  0.7512423051567048  0.9119041361916302  0.5868388894943912  0.3600554448403415  0.4419034543022882 ]
      [ 0.8225964245706265  0.01608615513584155 0.1442007939324697  0.7623388321096165  0.8419745686508193  0.08792951865247645 0.2902529012579151 ]
      [ 0.8488187232786935  0.422866666087792 0.1057975175658363  0.07968277822379832 0.7526946339452074  0.7698915909784674  0.02831893268471575 ] ]

Operations
----------

A few linear algebra operations are available, wrapping BLAS:

    echo 3.5 * v6
    v6 *= 2.3
    echo v1 + v3
    echo v1 - v3
    echo v1 * v3 # dot product
    echo l_1(v1) # l_1 norm
    echo l_2(v1) # l_2 norm
    echo m3 * v3 # matrix-vector product
    echo m4 * m1 # matrix-matrix product
    echo m4.t # transpose, done in constant time without copying
    echo m1 + m4.t

Rewrite rules
-------------

A few rewrite rules allow to optimize a chain of linear algebra operations into a single BLAS call. For instance, if you try

  echo v1 + 5.3 * v3

this is not implemented as a scalar multiplication followed by a sum, but it is turned into a single function call.

Linking BLAS implementations
----------------------------

A few compile flags are available to link specific BLAS implementations

    -d:atlas
    -d:mkl
    -d:mkl -d:threaded

TODO
----

* More operations
* Add support for `float32`
* Add support for matrices and vectors whose size is only known at runtime
* Add support for matrices and vector on the stack, since dimensions are known at compile time anyway
* Use rewrite rules to optimize complex operations into a single BLAS call
* Move vectors and matrix to/from the GPU
* Run on the GPU via cuBLAS
* Add some tests
* Add operations from LAPACK
* Support slicing/nonconstant steps
* Make `row` and `column` operations non-copying
* Add a fallback Nim implementation of most operations, that is valid over other rings
* Try on more platforms/configurations
* Make a proper benchmark