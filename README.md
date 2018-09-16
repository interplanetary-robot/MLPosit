
MLPosit is a fast library for investigating the properties of 8- and 16-bit,
no exponent posits for the purposes of building machine learning hardware.

### Supported Platforms

-  Julia 1.0
-  C/C++
-  Javascript (ECMA 6.0)

### Coming Soon

-  Python

## Julia Library things

### Running in Julia

- NB: to go into shell mode, type `;`, to go into pkg mode type `]`

```julia
shell> cd path/to/MLPosit
(v1.1) pkg> activate .
julia> using MLPosit

julia> x = Posit8(1.0)
Posit8(1.0)

julia> y = Posit8(2.0)
Posit8(2.0)

julia> x + y
Posit8(3.0)
```

## Deep learning examples

#### MNIST-fcnn

Shows the ability to run fully connected, dense neural networks.  This process involves quite a few fused-multiply-adds so the ability of the value to accumulate in plain Posit8 is challenged.  Nonetheless, the accuracy is not very degraded.

##### How to run (note you won't get the same numbers necessarily):
```
  examples/directory> julia MNIST-float-train.jl
  examples/directory> julia MNIST-float-inference.jl

  inference accuracy with IEEE Float64: 0.9188166666666666

  examples/directory> julia MNIST-posit-inference.jl
  inference accuracy with 8-bit posits: 0.9141166666666667
```

#### MNIST-convnet

I will be working on a convnet implementation in the future.  The current impl
of convnets leverages the BLAS gemm! function which only works with built-in
datatypes.

#### Generating Fakespeare

Generating fake shakespeare demonstrates Posit8 ability to run LSTMs.  Because the stateful memory lines need to accumulate values over recurrence, the datatype gets challenged.  Character-RNNs tend to need really long
memories, longer than most RNNs, so if this works with Posit8 it's encouraging.

##### How to run:
```
  # comment-back-in lines with gpu()/cpu() if you have a gpu.

  # get the training set.  (dammit Stanford get your CA stuff worked out!)
  examples/directory> wget --no-check-certificate https://cs.stanford.edu/people/karpathy/char-rnn/shakespeare_input.txt

  # do a training run.
  examples/directory> julia charRNN-float-train.jl

  #rename your favorite checkpoint.
  examples/directory> mv charRNN-ckpt-<n>.bson charRNN-ckpt.bson

  #run inference in different datatypes!
  examples/directory> julia charRNN-multi-inference.jl
```

#### Float64
```
y.
Be tell so.

BRUTUS:
I have sting this immony drams,'--
So near my hand of France: no, feelord to be protect
for me besend him words lost before;
Child of this rediby unheeches, as we were my
never fear me's for prince I am reckonness will make
affectures thy changely go impatience.

FALSTAFF:
Sir, Authemation
With that say it Englo I'll tell you to seven calls,
On Beat to bear up did I doubled by the rests,
Nor mad, as first well begins
It since kindred from Cybbarians in frosters, hope.
My mistress for I will libbilitl the tit.

JOAN LA CUVINUS:
When thou arrow you decher from the careful fanher
You marry for this our fees of valia
For whorest thou nights so wives the most in, but to sinnman.
Were I sweet instation! whillow! where must this you now?
This head, let him lovanct all hither Helize,
And not alwounds the case!--Pay Scatro,
Give me deed of swrenger: reason hath sought in't.

PHEBE:
Swe are that the what thou hears him in faith.

COMINIUS:
Good discorrupt, sir, hear the m
```


#### Posit8
```
y,
Will evill houses to myself.

AENTARIUS:
I fill, gently, the match the gods, art.

THERSITUS:
Having, that youth of wall of sath he shold all of you
Take out o' thy'bassia,
As, water infoct'd; some put in faced,
Of noblend, if in bodness wildress.

EROS:
A challession to birst neared way
And to ye before I keep three hand of lived;
Welcome to-stewath, my directs,
Nay, give me the wind may naturans of speed.

GORIO:
Call himself one. What, most corrusiness is!
And, go with her cheeks,--leap miserable:
Swallow had hurriwas night to me,
Have more for over is too will art thou never,
The armide,
Or aptenced souls talciest, matten chokenty,
Who wadons: I say havine,' if then.

LEPIDES:
Watch wise from that,' and baced whice an honest,
For two front catches!

HORANDAR:
Sir, he was as yet,
And holour, falleed for where is besides,
I path in yours. Cist appreblest false will in an unnaturate marvines
came off far on thy most.
Tut it humblect'st of she leave me,
Come in almothers,
As of warn
```

#### Performance comparison:

Current code:

```julia
  # note: in julia 1.0
  as_posit(i::UInt8) = reinterpret(Posit8, i)

  # allocate an array of 10k inputs to add.
  const ivalues = rand(UInt8, 10000, 2)
  const pvalues = as_posit.(ivalues)

  #addition test
  perf_add(idx) = pvalues[idx, 1] + pvalues[idx, 2]
  perf_add(1)
  @time for idx = 1:10000
      perf_add(idx)
  end
```

result:
0.000252s

#### Comparison against old code

```julia
  # note: use julia 0.6.4
  using SigmoidNumbers

  # allocate an array of 10k inputs to add.
  const ivalues = rand(UInt8, 10000, 2)
  const pvalues = Posit{8,0}.(ivalues)

  # addition test
  perf_add(idx) = pvalues[idx, 1] + pvalues[idx, 2]
  perf_add(1)
  @time for idx = 1:10000
      perf_add(idx)
  end
```
result:
0.000609s

## C Library things

### Building the C/C++ library

The C/C++ library comes in the form of the shared library 'libmlposit.so'.
This will be generated into the ./bin directory.

```bash
  make build
  sudo make install #optional, if you'd like to install it into /usr/lib
```

### Using the C/C++ library

The C/C++ library defines the following types.  The Posit8 class can be used in
C++ programs, the posit8_t type can be used in C programs; both have size 1 byte.

```C++
  class Posit8;
  typedef posit8_t;
```

  the following functions are defined for conversion:

```C++
  float p8_to_f(posit8_t);
  posit8_t f_to_p8(float);

  Posit8::Posit8(float);
  Posit8::Posit8(double);
  Posit8::Posit8(posit8_t);
  Posit8::operator float();
  Posit8::operator double();
  Posit8::operator posit8_t();
```  

the following functions, plus the standard math overload operations (in C++) are
defined:

```C
  posit8_t posit8_add(const posit8_t, const posit8_t);  // addition
  posit8_t posit8_mul(const posit8_t, const posit8_t);  // multiplication
  posit8_t posit8_div(const posit8_t, const posit8_t);  // division
  posit8_t posit8_sub(const posit8_t, const posit8_t);  // subtraction
  posit8_t posit8_addinv(const posit8_t);               // ==> -x
  posit8_t posit8_mulinv(const posit8_t);               // ==> 1/x

  bool posit8_lt(const posit8_t, const posit8_t);
  bool posit8_lte(const posit8_t, const posit8_t);
  bool posit8_gt(const posit8_t, const posit8_t);
  bool posit8_gte(const posit8_t, const posit8_t);
  bool posit8_eq(const posit8_t, const posit8_t);
```  

No vector or matrix operations are defined, but (in C++) you may use the STL
vectors and matrix operations, which will "do the right thing".

## JS Library things

### using the javascript library

The javascript library is still a bit awkward since javascript doesn't support  
proper operator overloading.  Nonetheless some basic math is possible for use
in a forthcoming demonstration.  The library is located in `js/posit8.js`.  Unit
and comprehensive tests are forthcoming.

The following class is defined:
```javascript
  class Posit8 {
    constructor(value = null){
      ... // you can pass a floating point value or another posit to this constructor.
    }
    toString()
  }
```

The following functions are defined:

```javascript

function f_to_p8(x){...}; // outputs the respective number type
function p8_to_f(x){...}; // outputs the respective number type

function posit8_add(a, b){...}; // outputs a posit8
function posit8_sub(a, b){...}; // outputs a posit8
function posit8_mul(a, b){...}; // outputs a posit8
function posit8_div(a, b){...}; // outputs a posit8

function posit8_gt(a, b){...};  // outputs a bool
function posit8_gte(a, b){...}; // outputs a bool
function posit8_lt(a, b){...};  // outputs a bool
function posit8_lte(a, b){...}; // outputs a bool
function posit8_eq(a, b){...};  // outputs a bool

```

An example:
```javascript
  >> posit8_add(new Posit8(1.0), new Posit8(3.0)).toString()
  "Posit8(4)"
```
