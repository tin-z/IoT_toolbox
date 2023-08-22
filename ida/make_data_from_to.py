import ida_bytes
import ida_nalt

# Distributed under the MIT License (MIT)
# Copyright (c) 2023, Altin (tin-z)

DESC="""
Supports only standard data (no structure for now)
"""

from_ea = None
to_ea = None
typ_ea = "DW"


typ = {"B":(ida_bytes.byte_flag(),1), "W": (ida_bytes.word_flag(),2), "DW": (ida_bytes.dword_flag(),4), "QW": (ida_bytes.qword_flag(),8), "STR":(ida_bytes.strlit_flag(), -1)}



def _make_data(from_ea, to_ea, typ_ea):
    assert(from_ea != None and to_ea != None and typ_ea != None)
    typ_ea_flg, typ_len = typ[typ_ea]

    if typ_ea != "STR" :
        for i in range(from_ea, to_ea+1, typ_len) :
            rets = ida_bytes.create_data(i, typ_ea_flg, typ_len, ida_idaapi.BADADDR)
            if not rets :
                print("Cannot define addr '0x{:x}' as '{}' type ... maybe undefine it first (e.g. call _make_undef(from_ea, to_ea, typ_ea))".format(i, typ_ea))

    else :
        ea = from_ea
        srch_flg = idc.SEARCH_DOWN | idc.SEARCH_NEXT
        while ea < to_ea :

            if ida_bytes.is_data(ida_bytes.get_full_flags(ea)) :
                ea_data = ida_search.find_data(ea, srch_flg)
                ea_unk = ida_search.find_unknown(ea, srch_flg)
                ea = ea_data if ea_data < ea_unk else ea_unk

            rets = ida_bytes.create_strlit(ea, 0, ida_nalt.STRTYPE_TERMCHR)
            ea += 1



def _make_undef(from_ea, to_ea, typ_ea):
    assert(from_ea != None and to_ea != None and typ_ea != None)
    typ_ea_flg, typ_len = typ[typ_ea]
    for i in range(from_ea, to_ea+1, typ_len) :
        rets = ida_bytes.del_items(i, 1, typ_len)
        if not rets :
            print("Cannot undefine addr '0x{:x}' as '{}' type (size) ... don't know why".format(i, typ_ea))


def hrB():
    _make_data(here(), here()+1, "B")


def hrw():
    _make_data(here(), here()+2, "W")


def hrdw():
    _make_data(here(), here()+4, "DW")


def hrqw():
    _make_data(here(), here()+8, "QW")


def uhrB():
    _make_undef(here(), here()+1, "B")


def uhrw():
    _make_undef(here(), here()+2, "W")


def uhrdw():
    _make_undef(here(), here()+4, "DW")


def uhrqw():
    _make_undef(here(), here()+8, "QW")



#typ_ea="DW"
#_make_undef(from_ea, to_ea, typ_ea)
#_make_data(from_ea, to_ea, typ_ea)


