// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

#ifndef TT_UNITY_STANDARD_CORE_FORWARD_INCLUDED
#define TT_UNITY_STANDARD_CORE_FORWARD_INCLUDED

#if defined(UNITY_NO_FULL_STANDARD_SHADER)
#   define UNITY_STANDARD_SIMPLE 1
#endif

#include "TT_UnityStandardConfig.cginc"

#if 0
    #include "UnityStandardCoreForwardSimple.cginc"
    VertexOutputBaseSimple vertBase (VertexInput v) { return vertForwardBaseSimple(v); }
    VertexOutputForwardAddSimple vertAdd (VertexInput v) { return vertForwardAddSimple(v); }
    half4 fragBase (VertexOutputBaseSimple i) : SV_Target { return fragForwardBaseSimpleInternal(i); }
    half4 fragAdd (VertexOutputForwardAddSimple i) : SV_Target { return fragForwardAddSimpleInternal(i); }
#else
    #include "TT_UnityStandardCore.cginc"
    VertexOutputForwardBase vertBase (VertexInput v) { return vertForwardBase(v); }
    VertexOutputForwardAdd vertAdd (VertexInput v) { return vertForwardAdd(v); }
    half4 fragBase (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i); }
    half4 fragAdd (VertexOutputForwardAdd i) : SV_Target { return fragForwardAddInternal(i); }


    VertexOutputForwardBase vertBase_FurLayer1(VertexInput v) { return vertForwardBase(v, 0.05);}
    VertexOutputForwardBase vertBase_FurLayer2(VertexInput v) { return vertForwardBase(v, 0.1);}
    VertexOutputForwardBase vertBase_FurLayer3(VertexInput v) { return vertForwardBase(v, 0.15);}
    VertexOutputForwardBase vertBase_FurLayer4(VertexInput v) { return vertForwardBase(v, 0.2);}
    VertexOutputForwardBase vertBase_FurLayer5(VertexInput v) { return vertForwardBase(v, 0.25);}
    VertexOutputForwardBase vertBase_FurLayer6(VertexInput v) { return vertForwardBase(v, 0.3);}
    VertexOutputForwardBase vertBase_FurLayer7(VertexInput v) { return vertForwardBase(v, 0.35);}
    VertexOutputForwardBase vertBase_FurLayer8(VertexInput v) { return vertForwardBase(v, 0.4);}
    VertexOutputForwardBase vertBase_FurLayer9(VertexInput v) { return vertForwardBase(v, 0.45);}
    VertexOutputForwardBase vertBase_FurLayer10(VertexInput v) { return vertForwardBase(v, 0.5);}
    VertexOutputForwardBase vertBase_FurLayer11(VertexInput v) { return vertForwardBase(v, 0.55);}
    VertexOutputForwardBase vertBase_FurLayer12(VertexInput v) { return vertForwardBase(v, 0.6);}
    VertexOutputForwardBase vertBase_FurLayer13(VertexInput v) { return vertForwardBase(v, 0.65);}
    VertexOutputForwardBase vertBase_FurLayer14(VertexInput v) { return vertForwardBase(v, 0.7);}
    VertexOutputForwardBase vertBase_FurLayer15(VertexInput v) { return vertForwardBase(v, 0.75);}
    VertexOutputForwardBase vertBase_FurLayer16(VertexInput v) { return vertForwardBase(v, 0.8);}
    VertexOutputForwardBase vertBase_FurLayer17(VertexInput v) { return vertForwardBase(v, 0.85);}
    VertexOutputForwardBase vertBase_FurLayer18(VertexInput v) { return vertForwardBase(v, 0.9);}
    VertexOutputForwardBase vertBase_FurLayer19(VertexInput v) { return vertForwardBase(v, 0.95);}
    VertexOutputForwardBase vertBase_FurLayer20(VertexInput v) { return vertForwardBase(v, 1);}

    half4 fragBase_FurLayer1 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 0.05); }
    half4 fragBase_FurLayer2 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 0.1); }
    half4 fragBase_FurLayer3 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 0.15); }
    half4 fragBase_FurLayer4 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 0.2); }
    half4 fragBase_FurLayer5 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 0.25); }
    half4 fragBase_FurLayer6 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 0.3); }
    half4 fragBase_FurLayer7 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 0.35); }
    half4 fragBase_FurLayer8 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 0.4); }
    half4 fragBase_FurLayer9 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 0.45); }
    half4 fragBase_FurLayer10 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 0.5); }
    half4 fragBase_FurLayer11 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 0.55); }
    half4 fragBase_FurLayer12 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 0.6); }
    half4 fragBase_FurLayer13 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 0.65); }
    half4 fragBase_FurLayer14 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 0.7); }
    half4 fragBase_FurLayer15 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 0.75); }
    half4 fragBase_FurLayer16 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 0.8); }
    half4 fragBase_FurLayer17 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 0.85); }
    half4 fragBase_FurLayer18 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 0.9); }
    half4 fragBase_FurLayer19 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 0.95); }
    half4 fragBase_FurLayer20 (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i, 1); }
#endif

#endif // UNITY_STANDARD_CORE_FORWARD_INCLUDED
