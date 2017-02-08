import gf_typedef, gf_cpu, gf_error

proc gf_w4_scratch_size*(mult_type: cint; region_type: var cint; divide_type: cint; arg1: var cint; arg2: var cint): cint {.cdecl.} =

  if mult_type == cast[cint](GF_MULT_BYTWO_P) or mult_type == cast[cint](GF_MULT_BYTWO_b):
      return cast[cint](sizeof(cast[cint](gf_internal_t))) + cast[cint](sizeof(cast[cint](gf_bytwo_data)))

  elif mult_type == cast[cint](GF_MULT_DEFAULT) or mult_type == cast[cint](GF_MULT_TABLE):
      if region_type == cast[cint](GF_REGION_CAUCHY):
        return cast[cint](sizeof(cast[cint](gf_internal_t)) + sizeof(cast[gf_single_table_data](+ 64)))

      if mult_type == cast[cint](GF_MULT_DEFAULT) and not cast[bool](gf_cpu_supports_arm_neon or gf_cpu_supports_intel_ssse3):
         region_type = cast[cint](GF_REGION_DOUBLE_TABLE)

      if cast[bool](region_type and cast[cint](GF_REGION_DOUBLE_TABLE)):
         return cast[cint](sizeof(cast[cint](gf_internal_t)) + sizeof(cast[gf_double_table_data](+ 64)))

      elif cast[bool](region_type and cast[cint](GF_REGION_QUAD_TABLE)):
        if (region_type and cast[cint](GF_REGION_LAZY)) == 0:
           return cast[cint](sizeof(cast[cint](gf_internal_t)) + sizeof(cast[gf_quad_table_data](+ 64)))
        else:
           return cast[cint](sizeof(cast[cint](gf_internal_t)) + sizeof(cast[gf_quad_table_lazy_data](+ 64)))
      else:
         return cast[cint](sizeof(cast[cint](gf_internal_t)) + sizeof(cast[gf_single_table_data](+ 64)))

  elif cast[bool](GF_MULT_LOG_TABLE):
      return cast[cint](sizeof(cast[cint](gf_internal_t)) + sizeof(cast[gf_logtable_data](+ 64)))

  elif cast[bool](GF_MULT_CARRY_FREE):
      return  cast[cint](sizeof(gf_internal_t))
  elif cast[bool](GF_MULT_SHIFT):
      return cast[cint](sizeof(cast[cint](gf_internal_t)))
  else:
      return 0
  return 0

proc gf_w8_scratch_size*(mult_type: cint; region_type: var cint; divide_type: cint; arg1: var cint; arg2: var cint): cint {.cdecl.} =

  if mult_type == cast[cint](GF_MULT_DEFAULT):
     if cast[bool](gf_cpu_supports_intel_ssse3 or gf_cpu_supports_arm_neon):
      return cast[cint](sizeof(cast[cint](gf_internal_t)) + sizeof(cast[gf_w8_default_data](+ 64)))
     return cast[cint](sizeof(cast[cint](gf_internal_t)) + sizeof(cast[gf_w8_single_table_data](+ 64)))

  elif mult_type == cast[cint](GF_MULT_TABLE):
      if region_type == cast[cint](GF_REGION_CAUCHY):
          return cast[cint](sizeof(cast[cint](gf_internal_t)) + sizeof(cast[gf_w8_single_table_data](+ 64)))
      if region_type == GF_REGION_DEFAULT:
        return cast[cint](sizeof(cast[cint](gf_internal_t)) + sizeof(cast[gf_w8_single_table_data](+ 64)))

      if cast[bool](region_type and GF_REGION_DOUBLE_TABLE):
        if region_type == GF_REGION_DOUBLE_TABLE:
          return cast[cint](sizeof(cast[cint](gf_internal_t)) + sizeof(cast[gf_w8_double_table_data](+ 64)))
        elif region_type == (GF_REGION_DOUBLE_TABLE or GF_REGION_LAZY):
          return cast[cint](sizeof(cast[cint](gf_internal_t)) + sizeof(cast[gf_w8_double_table_lazy_data](+ 64)))
        else:
          return 0
      return 0

  elif mult_type == cast[cint](GF_MULT_BYTWO_p) or  mult_type == cast[cint](GF_MULT_BYTWO_b):
    return cast[cint](sizeof(cast[cint](gf_internal_t)) + sizeof(gf_w8_bytwo_data))

  elif mult_type == cast[cint](GF_MULT_SPLIT_TABLE):
    if (arg1 == 4 and arg2 == 8) or (arg1 == 8 and arg2 == 4):
      return cast[cint](sizeof(cast[cint](gf_internal_t)) + sizeof(cast[gf_w8_half_table_data](+ 64)))

  elif mult_type == cast[cint](GF_MULT_LOG_TABLE):
    return cast[cint](sizeof(cast[cint](gf_internal_t) + sizeof(cast[gf_w8_logtable_data](+ 64))))

  elif mult_type == cast[cint](GF_MULT_LOG_ZERO):
    return cast[cint](sizeof(cast[cint](gf_internal_t) + sizeof(cast[gf_w8_logzero_small_table_data](+ 64))))

  elif mult_type == cast[cint](GF_MULT_LOG_ZERO_EXT):
    return cast[cint](sizeof(cast[cint](gf_internal_t) + sizeof(cast[gf_w8_logzero_table_data](+ 64))))

  elif mult_type == cast[cint](GF_MULT_CARRY_FREE):
    return cast[cint](sizeof(cast[cint](gf_internal_t)))

  elif mult_type == cast[cint](GF_MULT_SHIFT):
    return cast[cint](sizeof(cast[cint](gf_internal_t)))

  elif mult_type == cast[cint](GF_MULT_COMPOSITE):
    return cast[cint](sizeof(cast[cint](gf_internal_t) + sizeof(cast[gf_w8_composite_data](+ 64))))

  else:
    return 0
  return 0

proc gf_w16_scratch_size*(mult_type: cint; region_type: cint; divide_type: cint; arg1: cint; arg2: cint): cint {.cdecl.} =

  if mult_type == cast[cint](GF_MULT_TABLE):
    return cast[cint](sizeof(cast[cint](gf_internal_t) + sizeof(cast[gf_w16_lazytable_data](+ 64))))

  elif mult_type == cast[cint](GF_MULT_BYTWO_p) or mult_type == cast[cint](GF_MULT_BYTWO_b):
    return cast[cint](sizeof(cast[cint](gf_internal_t) + sizeof(gf_w16_bytwo_data)))

  elif mult_type == cast[cint](GF_MULT_LOG_ZERO):
    return cast[cint](sizeof(cast[cint](gf_internal_t) + sizeof(cast[gf_w16_zero_logtable_data](+ 64))))

  elif mult_type == cast[cint](GF_MULT_LOG_TABLE):
    return cast[cint](sizeof(cast[cint](gf_internal_t) + sizeof(cast[gf_w16_logtable_data](+ 64))))

  elif mult_type == cast[cint](GF_MULT_DEFAULT) or mult_type == cast[cint](GF_MULT_SPLIT_TABLE):
    if arg1 == 8 and arg2 == 8:
      return cast[cint](sizeof(cast[cint](gf_internal_t) + sizeof(cast[gf_w16_split_8_8_data](+ 64))))

    elif (arg1 == 8 and arg2 == 16) or (arg2 == 8 and arg1 == 16):
      return cast[cint](sizeof(cast[cint](gf_internal_t) + sizeof(cast[gf_w16_logtable_data](+ 64))))

    elif mult_type == cast[cint](GF_MULT_DEFAULT) or (arg1 == 4 and arg2 == 16) or (arg2 == 4 and arg1 == 16):
      return cast[cint](sizeof(cast[cint](gf_internal_t) + sizeof(cast[gf_w16_logtable_data](+ 64))))
    return 0

  elif mult_type == cast[cint](GF_MULT_GROUP):
    return cast[cint](sizeof(cast[cint](gf_internal_t) + sizeof(cast[gf_w16_group_4_4_data](+ 64))))
  elif mult_type == cast[cint](GF_MULT_CARRY_FREE):
    return cast[cint](sizeof(cast[cint](gf_internal_t)))

  elif mult_type == cast[cint](GF_MULT_SHIFT):
    return cast[cint](sizeof((gf_internal_t)))
  elif mult_type == cast[cint](GF_MULT_COMPOSITE):
    return cast[cint](sizeof((gf_internal_t)) + sizeof(cast[gf_w16_composite_data](+ 64)))
  else:
    return 0
  return 0

proc gf_w32_scratch_size*(mult_type: cint; region_type: cint; divide_type: cint; arg1: cint; arg2: cint): cint {.cdecl.} =

  if mult_type == cast[cint](GF_MULT_BYTWO_p) or mult_type == cast[cint](GF_MULT_BYTWO_b):
    return cast[cint](sizeof(cast[cint](gf_internal_t) + sizeof(cast[gf_w32_bytwo_data](+ 64))))

  elif mult_type == cast[cint](GF_MULT_GROUP):
    return  cast[cint](sizeof(cast[cint](gf_internal_t) + sizeof(cast[gf_w32_group_data](+ sizeof(uint32))) * (1 shl arg1) + sizeof(uint32) * (1 shl arg2) + 64))

proc gf_scratch_size*(w: cint; mult_type: cint; region_type: var cint; divide_type: cint; arg1: var cint; arg2: var cint): cint {.cdecl.} =
  if gf_error_check(w, mult_type, region_type, divide_type, arg1, arg2, 0, nil) == 0:
    return 0

  case w
  of 4:
    return gf_w4_scratch_size(mult_type, region_type, divide_type, arg1, arg2)
  of 8:
    return gf_w8_scratch_size(mult_type, region_type, divide_type, arg1, arg2)
  of 16:
    return gf_w16_scratch_size(mult_type, region_type, divide_type, arg1, arg2)
  #of 32:
  #  return gf_w32_scratch_size(mult_type, region_type, divide_type, arg1, arg2)
  #of 64:
  #  return gf_w64_scratch_size(mult_type, region_type, divide_type, arg1, arg2)
  #of 128:
  #  return gf_w128_scratch_size(mult_type, region_type, divide_type, arg1, arg2)
  else:
      return 12
  #  return gf_wgen_scratch_size(w, mult_type, region_type, divide_type, arg1, arg2)

proc gf_init_easy*(gf: ptr gf_t; w: cint): cint {.cdecl.} =
  return w
  #return gf_init_hard(gf, w, GF_MULT_DEFAULT, GF_REGION_DEFAULT, GF_DIVIDE_DEFAULT, 0,
   #                  0, 0, nil, nil)

