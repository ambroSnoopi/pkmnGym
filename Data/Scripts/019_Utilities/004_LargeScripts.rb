#===============================================================================
# Load large script calls, which dont fit into the "Script..." window.
#===============================================================================

def berryPokemonMart(discount=false)
    if discount
        setPrice(:CHERIBERRY, 20)
    end
    pbPokemonMart([
        :CHERIBERRY    ,
        :CHESTOBERRY   ,
        :PECHABERRY    ,
        :RAWSTBERRY    ,
        :ASPEARBERRY   ,
        :LEPPABERRY    ,
        :ORANBERRY     ,
        :PERSIMBERRY   ,
        :LUMBERRY      ,
        :SITRUSBERRY   ,
        :FIGYBERRY     ,
        :WIKIBERRY     ,
        :MAGOBERRY     ,
        :AGUAVBERRY    ,
        :IAPAPABERRY   ,
        :RAZZBERRY     ,
        :BLUKBERRY     ,
        :NANABBERRY    ,
        :WEPEARBERRY   ,
        :PINAPBERRY    ,
        :POMEGBERRY    ,
        :KELPSYBERRY   ,
        :QUALOTBERRY   ,
        :HONDEWBERRY   ,
        :GREPABERRY    ,
        :TAMATOBERRY   ,
        :CORNNBERRY    ,
        :MAGOSTBERRY   ,
        :RABUTABERRY   ,
        :NOMELBERRY    ,
        :SPELONBERRY   ,
        :PAMTREBERRY   ,
        :WATMELBERRY   ,
        :DURINBERRY    ,
        :BELUEBERRY    ,
        :OCCABERRY     ,
        :PASSHOBERRY   ,
        :WACANBERRY    ,
        :RINDOBERRY    ,
        :YACHEBERRY    ,
        :CHOPLEBERRY   ,
        :KEBIABERRY    ,
        :SHUCABERRY    ,
        :COBABERRY     ,
        :PAYAPABERRY   ,
        :TANGABERRY    ,
        :CHARTIBERRY   ,
        :KASIBBERRY    ,
        :HABANBERRY    ,
        :COLBURBERRY   ,
        :BABIRIBERRY   ,
        :ROSELIBERRY   ,
        :CHILANBERRY   ,
        :LIECHIBERRY   ,
        :GANLONBERRY   ,
        :SALACBERRY    ,
        :PETAYABERRY   ,
        :APICOTBERRY   ,
        :LANSATBERRY   ,
        :STARFBERRY    ,
        :ENIGMABERRY   ,
        :MICLEBERRY    ,
        :CUSTAPBERRY   ,
        :JABOCABERRY   ,
        :ROWAPBERRY    ,
        :KEEBERRY      ,
        :MARANGABERRY
    ])
end


def tmPokemonMart(discount=false)
    if discount
        adapter = PokemonMartAdapter.new
        setPrice(:TM01, adapter.getPrice(:TM01,discount))
        setPrice(:TM02, adapter.getPrice(:TM02,discount))
        setPrice(:TM03, adapter.getPrice(:TM03,discount))
        setPrice(:TM04, adapter.getPrice(:TM04,discount))
        setPrice(:TM05, adapter.getPrice(:TM05,discount))
        setPrice(:TM06, adapter.getPrice(:TM06,discount))
        setPrice(:TM07, adapter.getPrice(:TM07,discount))
        setPrice(:TM08, adapter.getPrice(:TM08,discount))
        setPrice(:TM09, adapter.getPrice(:TM09,discount))
        setPrice(:TM10, adapter.getPrice(:TM10,discount))        
        setPrice(:TM11, adapter.getPrice(:TM11,discount))
        setPrice(:TM12, adapter.getPrice(:TM12,discount))
        setPrice(:TM13, adapter.getPrice(:TM13,discount))
        setPrice(:TM14, adapter.getPrice(:TM14,discount))
        setPrice(:TM15, adapter.getPrice(:TM15,discount))
        setPrice(:TM16, adapter.getPrice(:TM16,discount))
        setPrice(:TM17, adapter.getPrice(:TM17,discount))
        setPrice(:TM18, adapter.getPrice(:TM18,discount))
        setPrice(:TM19, adapter.getPrice(:TM19,discount))
        setPrice(:TM20, adapter.getPrice(:TM20,discount))
        setPrice(:TM21, adapter.getPrice(:TM21,discount))
        setPrice(:TM22, adapter.getPrice(:TM22,discount))
        setPrice(:TM23, adapter.getPrice(:TM23,discount))
        setPrice(:TM24, adapter.getPrice(:TM24,discount))
        setPrice(:TM25, adapter.getPrice(:TM25,discount))
        setPrice(:TM26, adapter.getPrice(:TM26,discount))
        setPrice(:TM27, adapter.getPrice(:TM27,discount))
        setPrice(:TM28, adapter.getPrice(:TM28,discount))
        setPrice(:TM29, adapter.getPrice(:TM29,discount))
        setPrice(:TM30, adapter.getPrice(:TM30,discount))
        setPrice(:TM31, adapter.getPrice(:TM31,discount))
        setPrice(:TM32, adapter.getPrice(:TM32,discount))
        setPrice(:TM33, adapter.getPrice(:TM33,discount))
        setPrice(:TM34, adapter.getPrice(:TM34,discount))
        setPrice(:TM35, adapter.getPrice(:TM35,discount))
        setPrice(:TM36, adapter.getPrice(:TM36,discount))
        setPrice(:TM37, adapter.getPrice(:TM37,discount))
        setPrice(:TM38, adapter.getPrice(:TM38,discount))
        setPrice(:TM39, adapter.getPrice(:TM39,discount))
        setPrice(:TM40, adapter.getPrice(:TM40,discount))
        setPrice(:TM41, adapter.getPrice(:TM41,discount))
        setPrice(:TM42, adapter.getPrice(:TM42,discount))
        setPrice(:TM43, adapter.getPrice(:TM43,discount))
        setPrice(:TM44, adapter.getPrice(:TM44,discount))
        setPrice(:TM45, adapter.getPrice(:TM45,discount))
        setPrice(:TM46, adapter.getPrice(:TM46,discount))
        setPrice(:TM47, adapter.getPrice(:TM47,discount))
        setPrice(:TM48, adapter.getPrice(:TM48,discount))
        setPrice(:TM49, adapter.getPrice(:TM49,discount))
        setPrice(:TM50, adapter.getPrice(:TM50,discount))
        setPrice(:TM51, adapter.getPrice(:TM51,discount))
        setPrice(:TM52, adapter.getPrice(:TM52,discount))
        setPrice(:TM53, adapter.getPrice(:TM53,discount))
        setPrice(:TM54, adapter.getPrice(:TM54,discount))
        setPrice(:TM55, adapter.getPrice(:TM55,discount))
        setPrice(:TM56, adapter.getPrice(:TM56,discount))
        setPrice(:TM57, adapter.getPrice(:TM57,discount))
        setPrice(:TM58, adapter.getPrice(:TM58,discount))
        setPrice(:TM59, adapter.getPrice(:TM59,discount))
        setPrice(:TM60, adapter.getPrice(:TM60,discount))
        setPrice(:TM61, adapter.getPrice(:TM61,discount))
        setPrice(:TM62, adapter.getPrice(:TM62,discount))
        setPrice(:TM63, adapter.getPrice(:TM63,discount))
        setPrice(:TM64, adapter.getPrice(:TM64,discount))
        setPrice(:TM65, adapter.getPrice(:TM65,discount))
        setPrice(:TM66, adapter.getPrice(:TM66,discount))
        setPrice(:TM67, adapter.getPrice(:TM67,discount))
        setPrice(:TM68, adapter.getPrice(:TM68,discount))
        setPrice(:TM69, adapter.getPrice(:TM69,discount))
        setPrice(:TM70, adapter.getPrice(:TM70,discount))
        setPrice(:TM71, adapter.getPrice(:TM71,discount))
        setPrice(:TM72, adapter.getPrice(:TM72,discount))
        setPrice(:TM73, adapter.getPrice(:TM73,discount))
        setPrice(:TM74, adapter.getPrice(:TM74,discount))
        setPrice(:TM75, adapter.getPrice(:TM75,discount))
        setPrice(:TM76, adapter.getPrice(:TM76,discount))
        setPrice(:TM77, adapter.getPrice(:TM77,discount))
        setPrice(:TM78, adapter.getPrice(:TM78,discount))
        setPrice(:TM79, adapter.getPrice(:TM79,discount))
        setPrice(:TM80, adapter.getPrice(:TM80,discount))
        setPrice(:TM81, adapter.getPrice(:TM81,discount))
        setPrice(:TM82, adapter.getPrice(:TM82,discount))
        setPrice(:TM83, adapter.getPrice(:TM83,discount))
        setPrice(:TM84, adapter.getPrice(:TM84,discount))
        setPrice(:TM85, adapter.getPrice(:TM85,discount))
        setPrice(:TM86, adapter.getPrice(:TM86,discount))
        setPrice(:TM87, adapter.getPrice(:TM87,discount))
        setPrice(:TM88, adapter.getPrice(:TM88,discount))
        setPrice(:TM89, adapter.getPrice(:TM89,discount))
        setPrice(:TM90, adapter.getPrice(:TM90,discount))
        setPrice(:TM91, adapter.getPrice(:TM91,discount))
        setPrice(:TM92, adapter.getPrice(:TM92,discount))
        setPrice(:TM93, adapter.getPrice(:TM93,discount))
        setPrice(:TM94, adapter.getPrice(:TM94,discount))
        setPrice(:TM95, adapter.getPrice(:TM95,discount))
        setPrice(:TM96, adapter.getPrice(:TM96,discount))
        setPrice(:TM97, adapter.getPrice(:TM97,discount))
        setPrice(:TM98, adapter.getPrice(:TM98,discount))
        setPrice(:TM99, adapter.getPrice(:TM99,discount))
        setPrice(:TM100, adapter.getPrice(:TM100,discount))
    end
    pbPokemonMart([
        :TM01,
        :TM02,
        :TM03,
        :TM04,
        :TM05,
        :TM06,
        :TM07,
        :TM08,
        :TM09,
        :TM10,
        :TM11,
        :TM12,
        :TM13,
        :TM14,
        :TM15,
        :TM16,
        :TM17,
        :TM18,
        :TM19,
        :TM20,
        :TM21,
        :TM22,
        :TM23,
        :TM24,
        :TM25,
        :TM26,
        :TM27,
        :TM28,
        :TM29,
        :TM30,
        :TM31,
        :TM32,
        :TM33,
        :TM34,
        :TM35,
        :TM36,
        :TM37,
        :TM38,
        :TM39,
        :TM40,
        :TM41,
        :TM42,
        :TM43,
        :TM44,
        :TM45,
        :TM46,
        :TM47,
        :TM48,
        :TM49,
        :TM50,
        :TM51,
        :TM52,
        :TM53,
        :TM54,
        :TM55,
        :TM56,
        :TM57,
        :TM58,
        :TM59,
        :TM60,
        :TM61,
        :TM62,
        :TM63,
        :TM64,
        :TM65,
        :TM66,
        :TM67,
        :TM68,
        :TM69,
        :TM70,
        :TM71,
        :TM72,
        :TM73,
        :TM74,
        :TM75,
        :TM76,
        :TM77,
        :TM78,
        :TM79,
        :TM80,
        :TM81,
        :TM82,
        :TM83,
        :TM84,
        :TM85,
        :TM86,
        :TM87,
        :TM88,
        :TM89,
        :TM90,
        :TM91,
        :TM92,
        :TM93,
        :TM94,
        :TM95,
        :TM96,
        :TM97,
        :TM98,
        :TM99,
        :TM100
    ])
end
