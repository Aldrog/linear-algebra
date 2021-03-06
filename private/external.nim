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

when defined(mkl):
  const header = "mkl.h"
  when defined(threaded):
    {. passl: "-lmkl_intel_lp64" passl: "-lmkl_core" passl: "-lmkl_gnu_thread" passl: "-lgomp" passl: "-lm" .}
  # {. passl: "-lmkl_intel_lp64" passl: "-lmkl_core" passl: "-lmkl_intel_thread" passl: "-lmpi" .}
    static: echo "--USING MKL THREADED--"
  else:
    {.passl: "-lmkl_intel_lp64" passl: "-lmkl_core" passl: "-lmkl_sequential" passl: "-lpthread" passl: "-lm" .}
    static: echo "--USING MKL SEQUENTIAL--"
else:
  when defined(atlas):
    {.passl: "-lcblas".}
    const header = "atlas/cblas.h"
    static: echo "--USING ATLAS--"
  else:
    when defined(openblas):
      {.passl: "-lopenblas".}
      const header = "cblas.h"
      static: echo "--USING OPENBLAS--"
    else:
      {.passl: "-lblas".}
      const header = "cblas.h"
      static: echo "--USING DEFAULT BLAS--"