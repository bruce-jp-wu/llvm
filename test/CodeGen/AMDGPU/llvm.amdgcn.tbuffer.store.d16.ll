; RUN: llc < %s -march=amdgcn -mcpu=tonga -verify-machineinstrs | FileCheck -enable-var-scope -check-prefix=GCN -check-prefix=UNPACKED %s
; RUN: llc < %s -march=amdgcn -mcpu=gfx810 -verify-machineinstrs | FileCheck -enable-var-scope -check-prefix=GCN -check-prefix=PACKED -check-prefix=GFX81 %s
; RUN: llc < %s -march=amdgcn -mcpu=gfx900 -verify-machineinstrs | FileCheck -enable-var-scope -check-prefix=GCN -check-prefix=PACKED -check-prefix=GFX9 %s


; GCN-LABEL: {{^}}tbuffer_store_d16_x:
; GCN: v_trunc_f16_e32 v[[LO:[0-9]+]], s{{[0-9]+}}
; GCN: tbuffer_store_format_d16_x v[[LO]], v{{[0-9]+}}, s[{{[0-9]+:[0-9]+}}],  dfmt:1,  nfmt:2, 0 idxen
define amdgpu_kernel void @tbuffer_store_d16_x(<4 x i32> %rsrc, half %data, i32 %vindex) {
main_body:
  call void @llvm.amdgcn.tbuffer.store.f16(half %data, <4 x i32> %rsrc, i32 %vindex, i32 0, i32 0, i32 0, i32 1, i32 2, i1 0, i1 0)
  ret void
}

; GCN-LABEL: {{^}}tbuffer_store_d16_xy:
; GCN: s_load_dword [[S_DATA:s[0-9]+]], s{{\[[0-9]+:[0-9]+\]}}, 0x34
; UNPACKED-DAG: s_lshr_b32 [[SHR:s[0-9]+]], [[S_DATA]], 16
; UNPACKED-DAG: s_and_b32 [[MASKED:s[0-9]+]], [[S_DATA]], 0xffff{{$}}
; UNPACKED-DAG: v_mov_b32_e32 v[[V_LO:[0-9]+]], [[MASKED]]
; UNPACKED-DAG: v_mov_b32_e32 v[[V_HI:[0-9]+]], [[SHR]]
; UNPACKED: tbuffer_store_format_d16_xy v{{\[}}[[V_LO]]:[[V_HI]]{{\]}}, v{{[0-9]+}}, s[{{[0-9]+:[0-9]+}}],  dfmt:1,  nfmt:2, 0 idxen

; PACKED: tbuffer_store_format_d16_xy v{{[0-9]+}}, v{{[0-9]+}}, s[{{[0-9]+:[0-9]+}}],  dfmt:1,  nfmt:2, 0 idxen
define amdgpu_kernel void @tbuffer_store_d16_xy(<4 x i32> %rsrc, <2 x half> %data, i32 %vindex) {
main_body:
  call void @llvm.amdgcn.tbuffer.store.v2f16(<2 x half> %data, <4 x i32> %rsrc, i32 %vindex, i32 0, i32 0, i32 0, i32 1, i32 2, i1 0, i1 0)
  ret void
}

; GCN-LABEL: {{^}}tbuffer_store_d16_xyzw:
; GCN-DAG: s_load_dword [[S_DATA_0:s[0-9]+]], s{{\[[0-9]+:[0-9]+\]}}, 0x34
; GCN-DAG: s_load_dword [[S_DATA_1:s[0-9]+]], s{{\[[0-9]+:[0-9]+\]}}, 0x38

; UNPACKED-DAG: s_mov_b32 [[K:s[0-9]+]], 0xffff{{$}}
; UNPACKED-DAG: s_lshr_b32 [[SHR0:s[0-9]+]], [[S_DATA_0]], 16
; UNPACKED-DAG: s_and_b32 [[MASKED0:s[0-9]+]], [[S_DATA_0]], [[K]]
; UNPACKED-DAG: s_lshr_b32 [[SHR1:s[0-9]+]], [[S_DATA_1]], 16
; UNPACKED-DAG: s_and_b32 [[MASKED1:s[0-9]+]], [[S_DATA_1]], [[K]]

; UNPACKED-DAG: v_mov_b32_e32 v[[LO:[0-9]+]], [[MASKED0]]
; UNPACKED-DAG: v_mov_b32_e32 v[[HI:[0-9]+]], [[SHR1]]
; UNPACKED: tbuffer_store_format_d16_xyzw v{{\[}}[[LO]]:[[HI]]{{\]}}, v{{[0-9]+}}, s[{{[0-9]+:[0-9]+}}],  dfmt:1,  nfmt:2, 0 idxen


; PACKED: v_mov_b32_e32 v[[LO:[0-9]+]], [[S_DATA_0]]
; PACKED: v_mov_b32_e32 v[[HI:[0-9]+]], [[S_DATA_1]]
; PACKED: tbuffer_store_format_d16_xyzw v{{\[}}[[LO]]:[[HI]]{{\]}}, v{{[0-9]+}}, s[{{[0-9]+:[0-9]+}}],  dfmt:1,  nfmt:2, 0 idxen
define amdgpu_kernel void @tbuffer_store_d16_xyzw(<4 x i32> %rsrc, <4 x half> %data, i32 %vindex) {
main_body:
  call void @llvm.amdgcn.tbuffer.store.v4f16(<4 x half> %data, <4 x i32> %rsrc, i32 %vindex, i32 0, i32 0, i32 0, i32 1, i32 2, i1 0, i1 0)
  ret void
}

declare void @llvm.amdgcn.tbuffer.store.f16(half, <4 x i32>, i32, i32, i32, i32, i32, i32, i1, i1)
declare void @llvm.amdgcn.tbuffer.store.v2f16(<2 x half>, <4 x i32>, i32, i32, i32, i32, i32, i32, i1, i1)
declare void @llvm.amdgcn.tbuffer.store.v4f16(<4 x half>, <4 x i32>, i32, i32, i32, i32, i32, i32, i1, i1)
