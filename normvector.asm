IF DEF(GBC)
	MACRO ___safeinc
		inc \1
	ENDM
ELSE
	MACRO ___safeinc
		inc LOW(\1)
		jr nz, :+
		inc HIGH(\1)
		:
	ENDM
ENDC

MACRO ___addproduct
	; ahl += \1 * \2
	; requires \3 = 0 and exits with \2 = 0
	:
	srl \2
	jr nc, :+
	add hl, \1
	adc \3
	:
	sla LOW(\1)
	rl HIGH(\1)
	rl \3
	inc \2
	dec \2
	jr nz, :--
ENDM

SECTION "Vector Normalization", ROMX, ALIGN[8]

VectorNormalizationTables:

.multiplication
	FOR ___first, 16
		FOR ___second, 16
			db LOW((16 - ___first) * (16 - ___second))
		ENDR
	ENDR
	PURGE ___first, ___second

	assert !LOW(@)

.unitvectors
	; for x = $20 to $40, for y = 1 to $40: x/sqrt(x^2 + y^2), y/sqrt(x^2 + y^2), in 0.16 fixed point
	; 8 rows per x value, 8 y values per row, 16 table entries per row, $1080 entries total
	dw $ffe0, $07ff, $ff80, $0ff8, $fee2, $17e5, $fe06, $1fc1, $fcee, $2785, $fb9e, $2f2e, $fa16, $36b5, $f85b, $3e17
	dw $f670, $4550, $f459, $4c5c, $f219, $5338, $efb3, $59e3, $ed2d, $605a, $ea89, $669c, $e7cc, $6ca8, $e4f9, $727d
	dw $e214, $781b, $df20, $7d82, $dc1f, $82b3, $d916, $87ae, $d607, $8c75, $d2f4, $9108, $cfe0, $9569, $cccd, $999a
	dw $c9bc, $9d9b, $c6af, $a16f, $c3a9, $a516, $c0a9, $a894, $bdb1, $abe9, $bac3, $af17, $b7df, $b220, $b505, $b505
	dw $b237, $b7c8, $af74, $ba6b, $acbe, $bcef, $aa14, $bf56, $a777, $c1a1, $a4e6, $c3d1, $a263, $c5e8, $9fec, $c7e7
	dw $9d82, $c9cf, $9b26, $cba1, $98d6, $cd5f, $9692, $cf09, $945c, $d0a1, $9231, $d227, $9013, $d39c, $8e01, $d501
	dw $8bfa, $d657, $89ff, $d79f, $8810, $d8d9, $862b, $da06, $8452, $db27, $8282, $dc3c, $80be, $dd46, $7f03, $de45
	dw $7d52, $df3a, $7bab, $e026, $7a0d, $e108, $7878, $e1e2, $76ed, $e2b3, $756a, $e37d, $73ef, $e43f, $727d, $e4f9
	dw $ffe2, $07c1, $ff88, $0f7d, $fef3, $172d, $fe24, $1ece, $fd1c, $265a, $fbdf, $2dcb, $fa6e, $351f, $f8cb, $3c50
	dw $f6fb, $435c, $f500, $4a3e, $f2dd, $50f4, $f096, $577c, $ee2f, $5dd5, $ebab, $63fb, $e90e, $69ef, $e65a, $6fb0
	dw $e394, $753d, $e0be, $7a96, $dddb, $7fbc, $daee, $84af, $d7fa, $8971, $d501, $8e01, $d206, $9261, $cf09, $9692
	dw $cc0e, $9a96, $c916, $9e6e, $c622, $a21c, $c334, $a5a0, $c04c, $a8fd, $bd6d, $ac34, $ba96, $af47, $b7c8, $b237
	dw $b505, $b505, $b24c, $b7b3, $af9f, $ba43, $acfc, $bcb6, $aa66, $bf0d, $a7db, $c14a, $a55c, $c36d, $a2ea, $c579
	dw $a084, $c76d, $9e2a, $c94c, $9bdc, $cb16, $999a, $cccd, $9764, $ce71, $9539, $d003, $931b, $d184, $9108, $d2f4
	dw $8f00, $d456, $8d04, $d5a9, $8b13, $d6ee, $892c, $d826, $8750, $d951, $857e, $da71, $83b6, $db85, $81f8, $dc8e
	dw $8044, $dd8d, $7e99, $de82, $7cf8, $df6d, $7b5f, $e050, $79cf, $e12a, $7848, $e1fc, $76c9, $e2c6, $7552, $e389
	dw $ffe4, $0787, $ff8f, $0f08, $ff02, $1680, $fe3f, $1de9, $fd47, $253f, $fc1b, $2c7d, $fabe, $33a0, $f932, $3aa2
	dw $f77a, $4182, $f599, $483c, $f392, $4ecd, $f168, $5534, $ef1e, $5b6d, $ecb8, $6179, $ea38, $6755, $e7a2, $6d01
	dw $e4f9, $727d, $e240, $77c7, $df79, $7ce2, $dca8, $81cc, $d9ce, $8687, $d6ee, $8b13, $d40a, $8f70, $d125, $93a2
	dw $ce3f, $97a7, $cb5b, $9b82, $c87a, $9f34, $c59d, $a2be, $c2c6, $a621, $bff5, $a960, $bd2c, $ac7b, $ba6b, $af74
	dw $b7b3, $b24c, $b505, $b505, $b261, $b7a0, $afc7, $ba1e, $ad37, $bc80, $aab3, $bec8, $a83a, $c0f7, $a5cc, $c30e
	dw $a36a, $c50f, $a113, $c6fa, $9ec8, $c8cf, $9c88, $ca92, $9a53, $cc41, $982a, $cdde, $960c, $cf6b, $93f9, $d0e7
	dw $91f1, $d254, $8ff4, $d3b1, $8e01, $d501, $8c19, $d644, $8a3a, $d779, $8866, $d8a3, $869c, $d9c1, $84dc, $dad3
	dw $8325, $dbdc, $8177, $dcda, $7fd2, $ddce, $7e36, $deba, $7ca3, $df9c, $7b18, $e077, $7995, $e149, $781b, $e214
	dw $ffe5, $0750, $ff95, $0e9b, $ff11, $15dd, $fe58, $1d11, $fd6d, $2434, $fc52, $2b41, $fb07, $3235, $f990, $390b
	dw $f7ef, $3fc1, $f626, $4654, $f439, $4cc1, $f22a, $5307, $effb, $5923, $edb1, $5f13, $eb4d, $64d8, $e8d3, $6a6f
	dw $e646, $6fd9, $e3a8, $7515, $e0fd, $7a23, $de45, $7f03, $db85, $83b6, $d8bd, $883c, $d5f1, $8c97, $d321, $90c6
	dw $d051, $94cc, $cd81, $98a9, $cab2, $9c5e, $c7e7, $9fec, $c520, $a355, $c25f, $a69a, $bfa3, $a9bd, $bcef, $acbe
	dw $ba43, $af9f, $b7a0, $b261, $b505, $b505, $b274, $b78d, $afec, $b9fa, $ad6f, $bc4d, $aafc, $be87, $a894, $c0a9
	dw $a636, $c2b4, $a3e3, $c4aa, $a19b, $c68b, $9f5e, $c859, $9d2b, $ca13, $9b03, $cbbb, $98e6, $cd53, $96d4, $ceda
	dw $94cc, $d051, $92ce, $d1b9, $90db, $d313, $8ef2, $d460, $8d12, $d59f, $8b3d, $d6d3, $8971, $d7fa, $87ae, $d916
	dw $85f5, $da28, $8444, $db2f, $829d, $dc2d, $80fe, $dd21, $7f67, $de0c, $7dd9, $deee, $7c53, $dfc9, $7ad5, $e09b
	dw $ffe7, $071c, $ff9b, $0e33, $ff1e, $1542, $fe6f, $1c45, $fd91, $2338, $fc84, $2a16, $fb4b, $30dd, $f9e7, $3789
	dw $f85b, $3e17, $f6a9, $4484, $f4d3, $4acf, $f2dd, $50f4, $f0c8, $56f3, $ee98, $5cc9, $ec4f, $6276, $e9f0, $67f9
	dw $e77d, $6d50, $e4f9, $727d, $e267, $777d, $dfc9, $7c53, $dd21, $80fe, $da71, $857e, $d7bb, $89d4, $d501, $8e01
	dw $d245, $9205, $cf89, $95e3, $cccd, $999a, $ca13, $9d2b, $c75c, $a099, $c4aa, $a3e3, $c1fd, $a70c, $bf56, $aa14
	dw $bcb6, $acfc, $ba1e, $afc7, $b78d, $b274, $b505, $b505, $b286, $b77b, $b010, $b9d8, $ada4, $bc1c, $ab41, $be49
	dw $a8e9, $c05e, $a69a, $c25f, $a456, $c44a, $a21c, $c622, $9fec, $c7e7, $9dc6, $c99a, $9bab, $cb3c, $999a, $cccd
	dw $9792, $ce4e, $9595, $cfc1, $93a2, $d125, $91b8, $d27b, $8fd8, $d3c4, $8e01, $d501, $8c33, $d632, $8a6f, $d757
	dw $88b4, $d872, $8701, $d982, $8557, $da88, $83b6, $db85, $821d, $dc78, $808c, $dd63, $7f03, $de45, $7d82, $df20
	dw $ffe8, $06eb, $ffa0, $0dd1, $ff2a, $14b0, $fe84, $1b84, $fdb2, $2248, $fcb3, $28fa, $fb8a, $2f97, $fa38, $361a
	dw $f8bf, $3c82, $f722, $42cb, $f563, $48f4, $f383, $4efa, $f187, $54dc, $ef6f, $5a99, $ed3f, $602e, $eaf9, $659c
	dw $e89f, $6ae1, $e634, $6ffe, $e3bb, $74f1, $e134, $79bb, $dea4, $7e5d, $dc0b, $82d6, $d96b, $8727, $d6c6, $8b50
	dw $d41e, $8f53, $d175, $9330, $cecb, $96e7, $cc23, $9a7b, $c97c, $9dec, $c6d9, $a13b, $c43b, $a469, $c1a1, $a777
	dw $bf0d, $aa66, $bc80, $ad37, $b9fa, $afec, $b77b, $b286, $b505, $b505, $b297, $b76b, $b032, $b9b8, $add6, $bbee
	dw $ab83, $be0d, $a939, $c018, $a6f9, $c20d, $a4c3, $c3ef, $a296, $c5be, $a073, $c77b, $9e5a, $c926, $9c4a, $cac1
	dw $9a44, $cc4c, $9848, $cdc9, $9655, $cf36, $946b, $d096, $928a, $d1e9, $90b3, $d32f, $8ee5, $d469, $8d1f, $d597
	dw $8b62, $d6ba, $89ae, $d7d3, $8803, $d8e1, $865f, $d9e6, $84c4, $dae2, $8330, $dbd5, $81a5, $dcbf, $8021, $dda1
	dw $ffe9, $06bc, $ffa5, $0d74, $ff35, $1426, $fe98, $1acd, $fdd0, $2165, $fcde, $27ed, $fbc4, $2e61, $fa82, $34bd
	dw $f91c, $3b00, $f792, $4126, $f5e8, $472f, $f41e, $4d17, $f238, $52dd, $f037, $5880, $ee1f, $5dff, $ebf0, $6358
	dw $e9ae, $688b, $e75b, $6d97, $e4f9, $727d, $e28a, $773b, $e010, $7bd3, $dd8d, $8044, $db02, $848f, $d872, $88b4
	dw $d5de, $8cb4, $d347, $908f, $d0b0, $9447, $ce18, $97dc, $cb82, $9b4f, $c8ee, $9ea1, $c65e, $a1d3, $c3d1, $a4e6
	dw $c14a, $a7db, $bec8, $aab3, $bc4d, $ad6f, $b9d8, $b010, $b76b, $b297, $b505, $b505, $b2a7, $b75b, $b052, $b99a
	dw $ae05, $bbc2, $abc1, $bdd5, $a986, $bfd4, $a754, $c1bf, $a52b, $c397, $a30b, $c55e, $a0f4, $c713, $9ee6, $c8b7
	dw $9ce2, $ca4c, $9ae7, $cbd1, $98f5, $cd48, $970b, $ceb1, $952b, $d00d, $9354, $d15c, $9185, $d29e, $8fbf, $d3d5
	dw $8e01, $d501, $8c4b, $d622, $8a9e, $d739, $88f9, $d846, $875c, $d94a, $85c7, $da44, $8439, $db36, $82b3, $dc1f
	dw $ffea, $0690, $ffaa, $0d1c, $ff3f, $13a2, $feaa, $1a1f, $fdec, $208e, $fd06, $26ed, $fbf9, $2d3a, $fac7, $3371
	dw $f972, $3990, $f7fa, $3f96, $f663, $457e, $f4ae, $4b49, $f2dd, $50f4, $f0f2, $567e, $eef0, $5be6, $ecd8, $612b
	dw $eaad, $664b, $e870, $6b47, $e624, $701f, $e3cb, $74d1, $e167, $795f, $def8, $7dc7, $dc82, $820b, $da06, $862b
	dw $d785, $8a28, $d501, $8e01, $d27b, $91b8, $cff4, $954d, $cd6e, $98c2, $cae9, $9c16, $c867, $9f4b, $c5e8, $a263
	dw $c36d, $a55c, $c0f7, $a83a, $be87, $aafc, $bc1c, $ada4, $b9b8, $b032, $b75b, $b2a7, $b505, $b505, $b2b7, $b74c
	dw $b070, $b97d, $ae32, $bb98, $abfc, $bda0, $a9cf, $bf94, $a7aa, $c175, $a58d, $c344, $a379, $c502, $a16f, $c6af
	dw $9f6c, $c84d, $9d73, $c9db, $9b82, $cb5b, $999a, $cccd, $97ba, $ce31, $95e3, $cf89, $9414, $d0d4, $924d, $d213
	dw $908f, $d347, $8ed9, $d471, $8d2b, $d58f, $8b84, $d6a4, $89e6, $d7b0, $884f, $d8b2, $86bf, $d9ab, $8537, $da9c
	dw $ffec, $0666, $ffae, $0cc9, $ff48, $1325, $febb, $1979, $fe06, $1fc1, $fd2b, $25fa, $fc2b, $2c21, $fb07, $3235
	dw $f9c2, $3832, $f85b, $3e17, $f6d6, $43e1, $f534, $4990, $f377, $4f20, $f1a1, $5492, $efb3, $59e3, $edb1, $5f13
	dw $eb9b, $6422, $e974, $690e, $e73d, $6dd7, $e4f9, $727d, $e2a9, $76ff, $e050, $7b5f, $ddee, $7f9c, $db85, $83b6
	dw $d916, $87ae, $d6a4, $8b84, $d42f, $8f3a, $d1b9, $92ce, $cf43, $9644, $cccd, $999a, $ca59, $9cd1, $c7e7, $9fec
	dw $c579, $a2ea, $c30e, $a5cc, $c0a9, $a894, $be49, $ab41, $bbee, $add6, $b99a, $b052, $b74c, $b2b7, $b505, $b505
	dw $b2c5, $b73d, $b08d, $b961, $ae5d, $bb71, $ac34, $bd6d, $aa14, $bf56, $a7fb, $c12e, $a5eb, $c2f4, $a3e3, $c4aa
	dw $a1e3, $c650, $9fec, $c7e7, $9dfd, $c96f, $9c16, $cae9, $9a37, $cc56, $9861, $cdb6, $9692, $cf09, $94cc, $d051
	dw $930e, $d18d, $9157, $d2be, $8fa8, $d3e5, $8e01, $d501, $8c61, $d614, $8ac9, $d71e, $8938, $d81e, $87ae, $d916
	dw $ffed, $063e, $ffb2, $0c79, $ff51, $12af, $feca, $18dc, $fe1e, $1efd, $fd4d, $2512, $fc59, $2b15, $fb43, $3107
	dw $fa0c, $36e3, $f8b6, $3ca9, $f741, $4256, $f5b1, $47e9, $f407, $4d60, $f244, $52ba, $f06a, $57f5, $ee7c, $5d11
	dw $ec7a, $620d, $ea68, $66e9, $e846, $6ba3, $e616, $703d, $e3da, $74b4, $e194, $790b, $df45, $7d40, $dcef, $8153
	dw $da92, $8547, $d832, $8919, $d5ce, $8ccc, $d368, $9060, $d101, $93d5, $ce9a, $972c, $cc33, $9a65, $c9cf, $9d82
	dw $c76d, $a084, $c50f, $a36a, $c2b4, $a636, $c05e, $a8e9, $be0d, $ab83, $bbc2, $ae05, $b97d, $b070, $b73d, $b2c5
	dw $b505, $b505, $b2d3, $b730, $b0a9, $b947, $ae86, $bb4b, $ac6a, $bd3c, $aa56, $bf1b, $a849, $c0ea, $a645, $c2a8
	dw $a448, $c456, $a253, $c5f5, $a066, $c785, $9e81, $c907, $9ca4, $ca7c, $9ace, $cbe4, $9901, $cd3f, $973b, $ce8f
	dw $957c, $cfd2, $93c6, $d10b, $9217, $d239, $906f, $d35d, $8ece, $d478, $8d35, $d589, $8ba3, $d690, $8a18, $d78f
	dw $ffed, $0618, $ffb6, $0c2d, $ff59, $123d, $fed9, $1845, $fe34, $1e43, $fd6d, $2434, $fc84, $2a16, $fb7b, $2fe7
	dw $fa51, $35a4, $f90a, $3b4b, $f7a6, $40dc, $f626, $4654, $f48e, $4bb2, $f2dd, $50f4, $f116, $561a, $ef3b, $5b23
	dw $ed4c, $600d, $eb4d, $64d8, $e93e, $6984, $e722, $6e10, $e4f9, $727d, $e2c6, $76c9, $e089, $7af6, $de45, $7f03
	dw $dbfb, $82f1, $d9ab, $86bf, $d757, $8a6f, $d501, $8e01, $d2a9, $9175, $d051, $94cc, $cdf9, $9807, $cba1, $9b26
	dw $c94c, $9e2a, $c6fa, $a113, $c4aa, $a3e3, $c25f, $a69a, $c018, $a939, $bdd5, $abc1, $bb98, $ae32, $b961, $b08d
	dw $b730, $b2d3, $b505, $b505, $b2e1, $b723, $b0c3, $b92e, $aeac, $bb26, $ac9d, $bd0d, $aa95, $bee3, $a894, $c0a9
	dw $a69a, $c25f, $a4a8, $c405, $a2be, $c59d, $a0db, $c727, $9eff, $c8a4, $9d2b, $ca13, $9b5f, $cb76, $999a, $cccd
	dw $97dc, $ce18, $9626, $cf58, $9476, $d08e, $92ce, $d1b9, $912e, $d2db, $8f94, $d3f2, $8e01, $d501, $8c75, $d607
	dw $ffee, $05f4, $ffb9, $0be5, $ff61, $11d1, $fee6, $17b6, $fe49, $1d91, $fd8b, $2361, $fcad, $2922, $fbae, $2ed3
	dw $fa92, $3472, $f959, $39fd, $f803, $3f72, $f694, $44d0, $f50c, $4a15, $f36c, $4f41, $f1b7, $5452, $efee, $5947
	dw $ee12, $5e1f, $ec25, $62da, $ea29, $6777, $e81f, $6bf7, $e609, $7058, $e3e7, $749a, $e1bd, $78be, $df8a, $7cc4
	dw $dd50, $80ac, $db11, $8476, $d8ce, $8822, $d687, $8bb1, $d43e, $8f24, $d1f4, $927a, $cfa9, $95b6, $cd5f, $98d6
	dw $cb16, $9bdc, $c8cf, $9ec8, $c68b, $a19b, $c44a, $a456, $c20d, $a6f9, $bfd4, $a986, $bda0, $abfc, $bb71, $ae5d
	dw $b947, $b0a9, $b723, $b2e1, $b505, $b505, $b2ed, $b717, $b0dc, $b916, $aed1, $bb04, $acce, $bce1, $aad1, $beae
	dw $a8db, $c06b, $a6ec, $c218, $a504, $c3b8, $a324, $c549, $a14a, $c6cd, $9f78, $c844, $9dad, $c9ae, $9be9, $cb0c
	dw $9a2c, $cc5e, $9877, $cda6, $96c8, $cee2, $9520, $d015, $937f, $d13d, $91e5, $d25c, $9051, $d371, $8ec5, $d47e
	dw $ffef, $05d1, $ffbc, $0ba0, $ff68, $116a, $fef3, $172d, $fe5d, $1ce8, $fda7, $2297, $fcd2, $2839, $fbdf, $2dcb
	dw $facf, $334d, $f9a2, $38bc, $f85b, $3e17, $f6fb, $435c, $f582, $4889, $f3f3, $4d9f, $f24e, $529b, $f096, $577c
	dw $eecc, $5c43, $ecf1, $60ee, $eb06, $657d, $e90e, $69ef, $e709, $6e44, $e4f9, $727d, $e2e0, $7698, $e0be, $7a96
	dw $de95, $7e77, $dc66, $823c, $da32, $85e4, $d7fa, $8971, $d5c0, $8ce1, $d384, $9037, $d147, $9372, $cf09, $9692
	dw $cccd, $999a, $ca92, $9c88, $c859, $9f5e, $c622, $a21c, $c3ef, $a4c3, $c1bf, $a754, $bf94, $a9cf, $bd6d, $ac34
	dw $bb4b, $ae86, $b92e, $b0c3, $b717, $b2ed, $b505, $b505, $b2f9, $b70b, $b0f4, $b8ff, $aef5, $bae3, $acfc, $bcb6
	dw $ab0a, $be7a, $a91f, $c02f, $a73a, $c1d5, $a55c, $c36d, $a385, $c4f8, $a1b5, $c676, $9fec, $c7e7, $9e2a, $c94c
	dw $9c6e, $caa6, $9ab9, $cbf4, $990b, $cd37, $9764, $ce71, $95c3, $cfa0, $9429, $d0c5, $9295, $d1e1, $9108, $d2f4
	dw $fff0, $05b0, $ffbf, $0b5e, $ff6f, $1107, $feff, $16ab, $fe6f, $1c45, $fdc1, $21d5, $fcf5, $2759, $fc0c, $2ccf
	dw $fb07, $3235, $f9e7, $3789, $f8ae, $3cca, $f75b, $41f6, $f5f1, $470d, $f471, $4c0d, $f2dd, $50f4, $f135, $55c3
	dw $ef7b, $5a78, $edb1, $5f13, $ebd7, $6394, $e9f0, $67f9, $e7fc, $6c42, $e5fd, $7070, $e3f4, $7482, $e1e2, $7878
	dw $dfc9, $7c53, $dda9, $8012, $db85, $83b6, $d95c, $873f, $d730, $8aad, $d501, $8e01, $d2d1, $913b, $d0a1, $945c
	dw $ce71, $9764, $cc41, $9a53, $ca13, $9d2b, $c7e7, $9fec, $c5be, $a296, $c397, $a52b, $c175, $a7aa, $bf56, $aa14
	dw $bd3c, $ac6a, $bb26, $aeac, $b916, $b0dc, $b70b, $b2f9, $b505, $b505, $b305, $b6ff, $b10b, $b8e9, $af17, $bac3
	dw $ad29, $bc8d, $ab41, $be49, $a960, $bff5, $a785, $c194, $a5b1, $c326, $a3e3, $c4aa, $a21c, $c622, $a05b, $c78e
	dw $9ea1, $c8ee, $9ced, $ca43, $9b40, $cb8d, $999a, $cccd, $97f9, $ce02, $9660, $cf2e, $94cc, $d051, $933f, $d16a
	dw $fff1, $0590, $ffc2, $0b1f, $ff75, $10a9, $ff0a, $162d, $fe80, $1baa, $fdda, $211c, $fd16, $2683, $fc37, $2bdd
	dw $fb3d, $3128, $fa28, $3662, $f8fb, $3b8a, $f7b6, $409f, $f65a, $459f, $f4e9, $4a8a, $f363, $4f5e, $f1cb, $541a
	dw $f020, $58be, $ee66, $5d49, $ec9c, $61bb, $eac5, $6613, $e8e1, $6a51, $e6f2, $6e74, $e4f9, $727d, $e2f7, $766b
	dw $e0ee, $7a3e, $dedd, $7df7, $dcc7, $8196, $daad, $851b, $d88f, $8886, $d66e, $8bd8, $d44b, $8f11, $d227, $9231
	dw $d003, $9539, $cdde, $982a, $cbbb, $9b03, $c99a, $9dc6, $c77b, $a073, $c55e, $a30b, $c344, $a58d, $c12e, $a7fb
	dw $bf1b, $aa56, $bd0d, $ac9d, $bb04, $aed1, $b8ff, $b0f4, $b6ff, $b305, $b505, $b505, $b310, $b6f5, $b121, $b8d4
	dw $af37, $baa5, $ad54, $bc66, $ab76, $be19, $a99e, $bfbe, $a7cd, $c156, $a602, $c2e1, $a43d, $c45f, $a27e, $c5d1
	dw $a0c6, $c738, $9f14, $c893, $9d68, $c9e4, $9bc2, $cb2a, $9a23, $cc66, $9889, $cd98, $96f6, $cec1, $9569, $cfe0
	dw $fff1, $0572, $ffc5, $0ae2, $ff7b, $104f, $ff14, $15b5, $fe90, $1b15, $fdf0, $206b, $fd35, $25b6, $fc5f, $2af5
	dw $fb6f, $3026, $fa65, $3547, $f944, $3a57, $f80b, $3f55, $f6bc, $443f, $f559, $4915, $f3e1, $4dd6, $f258, $5280
	dw $f0bc, $5713, $ef11, $5b8f, $ed57, $5ff2, $eb8f, $643d, $e9bb, $686f, $e7db, $6c87, $e5f2, $7087, $e3ff, $746c
	dw $e204, $7839, $e002, $7beb, $ddfb, $7f85, $dbee, $8306, $d9dd, $866d, $d7ca, $89bd, $d5b4, $8cf4, $d39c, $9013
	dw $d184, $931b, $cf6b, $960c, $cd53, $98e6, $cb3c, $9bab, $c926, $9e5a, $c713, $a0f4, $c502, $a379, $c2f4, $a5eb
	dw $c0ea, $a849, $bee3, $aa95, $bce1, $acce, $bae3, $aef5, $b8e9, $b10b, $b6f5, $b310, $b505, $b505, $b31b, $b6ea
	dw $b136, $b8c0, $af56, $ba87, $ad7d, $bc40, $aba8, $bdeb, $a9da, $bf89, $a812, $c11a, $a650, $c29f, $a493, $c417
	dw $a2dd, $c584, $a12c, $c6e5, $9f82, $c83c, $9dde, $c988, $9c3f, $caca, $9aa7, $cc02, $9914, $cd31, $9787, $ce56
	dw $fff2, $0555, $ffc7, $0aa8, $ff80, $0ff8, $ff1e, $1542, $fe9f, $1a86, $fe06, $1fc1, $fd52, $24f1, $fc84, $2a16
	dw $fb9e, $2f2e, $fa9e, $3436, $f988, $392f, $f85b, $3e17, $f719, $42ec, $f5c3, $47ae, $f459, $4c5c, $f2dd, $50f4
	dw $f150, $5577, $efb3, $59e3, $ee08, $5e38, $ec4f, $6276, $ea89, $669c, $e8b8, $6aaa, $e6dd, $6e9f, $e4f9, $727d
	dw $e30d, $7641, $e119, $79ee, $df20, $7d82, $dd21, $80fe, $db1d, $8462, $d916, $87ae, $d70d, $8ae3, $d501, $8e01
	dw $d2f4, $9108, $d0e7, $93f9, $ceda, $96d4, $cccd, $999a, $cac1, $9c4a, $c8b7, $9ee6, $c6af, $a16f, $c4aa, $a3e3
	dw $c2a8, $a645, $c0a9, $a894, $beae, $aad1, $bcb6, $acfc, $bac3, $af17, $b8d4, $b121, $b6ea, $b31b, $b505, $b505
	dw $b325, $b6e0, $b14a, $b8ad, $af74, $ba6b, $ada4, $bc1c, $abd9, $bdc0, $aa14, $bf56, $a854, $c0e0, $a69a, $c25f
	dw $a4e6, $c3d1, $a338, $c539, $a18f, $c695, $9fec, $c7e7, $9e4f, $c92f, $9cb7, $ca6d, $9b26, $cba1, $999a, $cccd
	dw $fff2, $0539, $ffc9, $0a71, $ff86, $0fa5, $ff27, $14d4, $fead, $19fd, $fe1a, $1f1d, $fd6d, $2434, $fca8, $2940
	dw $fbca, $2e3f, $fad4, $3331, $f9c9, $3813, $f8a7, $3ce5, $f771, $41a6, $f626, $4654, $f4ca, $4aef, $f35b, $4f76
	dw $f1dc, $53e9, $f04d, $5846, $eeaf, $5c8d, $ed04, $60be, $eb4d, $64d8, $e98a, $68db, $e7be, $6cc7, $e5e7, $709b
	dw $e409, $7458, $e223, $77fe, $e037, $7b8c, $de45, $7f03, $dc4f, $8263, $da54, $85ac, $d857, $88de, $d657, $8bfa
	dw $d456, $8f00, $d254, $91f1, $d051, $94cc, $ce4e, $9792, $cc4c, $9a44, $ca4c, $9ce2, $c84d, $9f6c, $c650, $a1e3
	dw $c456, $a448, $c25f, $a69a, $c06b, $a8db, $be7a, $ab0a, $bc8d, $ad29, $baa5, $af37, $b8c0, $b136, $b6e0, $b325
	dw $b505, $b505, $b32f, $b6d7, $b15d, $b89a, $af91, $ba50, $adc9, $bbf9, $ac08, $bd95, $aa4b, $bf25, $a894, $c0a9
	dw $a6e2, $c221, $a536, $c38e, $a38f, $c4f0, $a1ee, $c648, $a052, $c795, $9ebc, $c8d9, $9d2b, $ca13, $9ba0, $cb44
	dw $fff3, $051e, $ffcc, $0a3b, $ff8a, $0f55, $ff2f, $146a, $febb, $1979, $fe2d, $1e80, $fd87, $237e, $fcc9, $2872
	dw $fbf3, $2d5a, $fb07, $3235, $fa05, $3701, $f8ee, $3bbe, $f7c3, $406b, $f685, $4506, $f534, $4990, $f3d2, $4e06
	dw $f260, $5268, $f0de, $56b6, $ef4e, $5af0, $edb1, $5f13, $ec07, $6322, $ea52, $671a, $e893, $6afc, $e6ca, $6ec7
	dw $e4f9, $727d, $e321, $761b, $e141, $79a3, $df5d, $7d15, $dd73, $8071, $db85, $83b6, $d993, $86e6, $d79f, $89ff
	dw $d5a9, $8d04, $d3b1, $8ff4, $d1b9, $92ce, $cfc1, $9595, $cdc9, $9848, $cbd1, $9ae7, $c9db, $9d73, $c7e7, $9fec
	dw $c5f5, $a253, $c405, $a4a8, $c218, $a6ec, $c02f, $a91f, $be49, $ab41, $bc66, $ad54, $ba87, $af56, $b8ad, $b14a
	dw $b6d7, $b32f, $b505, $b505, $b338, $b6cd, $b170, $b889, $afac, $ba36, $adee, $bbd8, $ac34, $bd6d, $aa80, $bef6
	dw $a8d1, $c073, $a727, $c1e6, $a582, $c34d, $a3e3, $c4aa, $a249, $c5fd, $a0b4, $c746, $9f25, $c886, $9d9b, $c9bc
	dw $fff3, $0505, $ffce, $0a08, $ff8f, $0f08, $ff37, $1404, $fec7, $18fa, $fe3f, $1de9, $fd9f, $22d0, $fce8, $27ac
	dw $fc1b, $2c7d, $fb37, $3142, $fa3f, $35f9, $f932, $3aa2, $f811, $3f3c, $f6de, $43c4, $f599, $483c, $f443, $4ca2
	dw $f2dd, $50f4, $f168, $5534, $efe5, $595f, $ee54, $5d76, $ecb8, $6179, $eb10, $6566, $e95e, $693e, $e7a2, $6d01
	dw $e5de, $70ae, $e412, $7446, $e240, $77c7, $e067, $7b34, $de8a, $7e8b, $dca8, $81cc, $dac2, $84f8, $d8d9, $8810
	dw $d6ee, $8b13, $d501, $8e01, $d313, $90db, $d125, $93a2, $cf36, $9655, $cd48, $98f5, $cb5b, $9b82, $c96f, $9dfd
	dw $c785, $a066, $c59d, $a2be, $c3b8, $a504, $c1d5, $a73a, $bff5, $a960, $be19, $ab76, $bc40, $ad7d, $ba6b, $af74
	dw $b89a, $b15d, $b6cd, $b338, $b505, $b505, $b341, $b6c5, $b181, $b877, $afc7, $ba1e, $ae11, $bbb7, $ac5f, $bd46
	dw $aab3, $bec8, $a90c, $c040, $a76a, $c1ac, $a5cc, $c30e, $a434, $c467, $a2a1, $c5b5, $a113, $c6fa, $9f8a, $c835
	dw $fff4, $04ec, $ffd0, $09d7, $ff93, $0ebf, $ff3f, $13a2, $fed3, $1881, $fe50, $1d58, $fdb6, $2227, $fd06, $26ed
	dw $fc40, $2ba9, $fb65, $3058, $fa75, $34fb, $f972, $3990, $f85b, $3e17, $f733, $428e, $f5f9, $46f4, $f4ae, $4b49
	dw $f354, $4f8d, $f1eb, $53be, $f074, $57db, $eef0, $5be6, $ed60, $5fdd, $ebc5, $63bf, $ea1f, $678e, $e870, $6b47
	dw $e6b8, $6eec, $e4f9, $727d, $e333, $75f8, $e167, $795f, $df95, $7cb1, $ddbe, $7fee, $dbe4, $8317, $da06, $862b
	dw $d826, $892c, $d644, $8c19, $d460, $8ef2, $d27b, $91b8, $d096, $946b, $ceb1, $970b, $cccd, $999a, $cae9, $9c16
	dw $c907, $9e81, $c727, $a0db, $c549, $a324, $c36d, $a55c, $c194, $a785, $bfbe, $a99e, $bdeb, $aba8, $bc1c, $ada4
	dw $ba50, $af91, $b889, $b170, $b6c5, $b341, $b505, $b505, $b34a, $b6bc, $b193, $b867, $afe0, $ba06, $ae32, $bb98
	dw $ac89, $bd20, $aae4, $be9c, $a944, $c00e, $a7aa, $c175, $a613, $c2d2, $a482, $c425, $a2f6, $c56f, $a16f, $c6af
	dw $fff4, $04d4, $ffd1, $09a7, $ff97, $0e78, $ff46, $1344, $fede, $180b, $fe60, $1ccc, $fdcc, $2185, $fd22, $2635
	dw $fc63, $2adc, $fb90, $2f77, $faa9, $3406, $f9ae, $3888, $f8a1, $3cfc, $f783, $4161, $f653, $45b7, $f513, $49fc
	dw $f3c4, $4e31, $f267, $5253, $f0fc, $5664, $ef84, $5a62, $ee00, $5e4d, $ec71, $6225, $ead7, $65e9, $e934, $699a
	dw $e789, $6d37, $e5d6, $70c0, $e41b, $7434, $e25a, $7795, $e094, $7ae2, $dec9, $7e1b, $dcfa, $8140, $db27, $8452
	dw $d951, $8750, $d779, $8a3a, $d59f, $8d12, $d3c4, $8fd8, $d1e9, $928a, $d00d, $952b, $ce31, $97ba, $cc56, $9a37
	dw $ca7c, $9ca4, $c8a4, $9eff, $c6cd, $a14a, $c4f8, $a385, $c326, $a5b1, $c156, $a7cd, $bf89, $a9da, $bdc0, $abd9
	dw $bbf9, $adc9, $ba36, $afac, $b877, $b181, $b6bc, $b34a, $b505, $b505, $b352, $b6b4, $b1a3, $b857, $aff8, $b9ee
	dw $ae52, $bb7a, $acb1, $bcfb, $ab14, $be72, $a97b, $bfdd, $a7e7, $c13f, $a658, $c297, $a4ce, $c3e6, $a348, $c52b
	dw $fff5, $04bd, $ffd3, $097a, $ff9b, $0e33, $ff4d, $12e9, $fee9, $179a, $fe6f, $1c45, $fde0, $20e9, $fd3c, $2584
	dw $fc84, $2a16, $fbb8, $2e9d, $fad9, $3319, $f9e7, $3789, $f8e4, $3beb, $f7cf, $403f, $f6a9, $4484, $f574, $48ba
	dw $f42f, $4ce0, $f2dd, $50f4, $f17d, $54f8, $f010, $58ea, $ee98, $5cc9, $ed14, $6097, $eb87, $6451, $e9f0, $67f9
	dw $e850, $6b8d, $e6a8, $6f0f, $e4f9, $727d, $e344, $75d7, $e189, $791f, $dfc9, $7c53, $de04, $7f74, $dc3c, $8282
	dw $da71, $857e, $d8a3, $8866, $d6d3, $8b3d, $d501, $8e01, $d32f, $90b3, $d15c, $9354, $cf89, $95e3, $cdb6, $9861
	dw $cbe4, $9ace, $ca13, $9d2b, $c844, $9f78, $c676, $a1b5, $c4aa, $a3e3, $c2e1, $a602, $c11a, $a812, $bf56, $aa14
	dw $bd95, $ac08, $bbd8, $adee, $ba1e, $afc7, $b867, $b193, $b6b4, $b352, $b505, $b505, $b35a, $b6ac, $b1b3, $b848
	dw $b010, $b9d8, $ae71, $bb5d, $acd7, $bcd8, $ab41, $be49, $a9b0, $bfaf, $a823, $c10b, $a69a, $c25f, $a516, $c3a9
	dw $fff5, $04a7, $ffd5, $094e, $ff9f, $0df1, $ff53, $1292, $fef3, $172d, $fe7d, $1bc3, $fdf4, $2052, $fd56, $24d9
	dw $fca4, $2957, $fbdf, $2dcb, $fb07, $3235, $fa1e, $3692, $f923, $3ae3, $f817, $3f26, $f6fb, $435c, $f5cf, $4782
	dw $f495, $4b99, $f34d, $4fa0, $f1f8, $5397, $f096, $577c, $ef29, $5b51, $edb1, $5f13, $ec2e, $62c4, $eaa2, $6663
	dw $e90e, $69ef, $e771, $6d69, $e5ce, $70d0, $e423, $7425, $e273, $7767, $e0be, $7a96, $df04, $7db3, $dd46, $80be
	dw $db85, $83b6, $d9c1, $869c, $d7fa, $8971, $d632, $8c33, $d469, $8ee5, $d29e, $9185, $d0d4, $9414, $cf09, $9692
	dw $cd3f, $9901, $cb76, $9b5f, $c9ae, $9dad, $c7e7, $9fec, $c622, $a21c, $c45f, $a43d, $c29f, $a650, $c0e0, $a854
	dw $bf25, $aa4b, $bd6d, $ac34, $bbb7, $ae11, $ba06, $afe0, $b857, $b1a3, $b6ac, $b35a, $b505, $b505, $b362, $b6a5
	dw $b1c2, $b839, $b027, $b9c2, $ae8f, $bb41, $acfc, $bcb6, $ab6d, $be21, $a9e3, $bf82, $a85c, $c0d9, $a6da, $c228
	dw $fff6, $0492, $ffd6, $0923, $ffa2, $0db2, $ff59, $123d, $fefc, $16c4, $fe8b, $1b46, $fe06, $1fc1, $fd6d, $2434
	dw $fcc2, $289f, $fc03, $2d01, $fb33, $3158, $fa51, $35a4, $f95e, $39e4, $f85b, $3e17, $f748, $423d, $f626, $4654
	dw $f4f6, $4a5d, $f3b8, $4e57, $f26d, $5240, $f116, $561a, $efb3, $59e3, $ee46, $5d9b, $ecce, $6142, $eb4d, $64d8
	dw $e9c3, $685c, $e832, $6bce, $e699, $6f2e, $e4f9, $727d, $e354, $75b9, $e1a9, $78e4, $dff9, $7bfc, $de45, $7f03
	dw $dc8e, $81f8, $dad3, $84dc, $d916, $87ae, $d757, $8a6f, $d597, $8d1f, $d3d5, $8fbf, $d213, $924d, $d051, $94cc
	dw $ce8f, $973b, $cccd, $999a, $cb0c, $9be9, $c94c, $9e2a, $c78e, $a05b, $c5d1, $a27e, $c417, $a493, $c25f, $a69a
	dw $c0a9, $a894, $bef6, $aa80, $bd46, $ac5f, $bb98, $ae32, $b9ee, $aff8, $b848, $b1b3, $b6a5, $b362, $b505, $b505
	dw $b369, $b69d, $b1d1, $b82b, $b03d, $b9ae, $aeac, $bb26, $ad20, $bc95, $ab98, $bdfa, $aa14, $bf56, $a894, $c0a9
	dw $fff6, $047e, $ffd8, $08fa, $ffa5, $0d74, $ff5f, $11ec, $ff05, $165f, $fe98, $1acd, $fe17, $1f34, $fd84, $2395
	dw $fcde, $27ed, $fc26, $2c3d, $fb5d, $3082, $fa82, $34bd, $f997, $38ed, $f89c, $3d10, $f792, $4126, $f679, $4530
	dw $f552, $492b, $f41e, $4d17, $f2dd, $50f4, $f190, $54c2, $f037, $5880, $eed4, $5c2e, $ed67, $5fcb, $ebf0, $6358
	dw $ea71, $66d3, $e8ea, $6a3e, $e75b, $6d97, $e5c6, $70df, $e42b, $7416, $e28a, $773b, $e0e4, $7a4f, $df3a, $7d52
	dw $dd8d, $8044, $dbdc, $8325, $da28, $85f5, $d872, $88b4, $d6ba, $8b62, $d501, $8e01, $d347, $908f, $d18d, $930e
	dw $cfd2, $957c, $ce18, $97dc, $cc5e, $9a2c, $caa6, $9c6e, $c8ee, $9ea1, $c738, $a0c6, $c584, $a2dd, $c3d1, $a4e6
	dw $c221, $a6e2, $c073, $a8d1, $bec8, $aab3, $bd20, $ac89, $bb7a, $ae52, $b9d8, $b010, $b839, $b1c2, $b69d, $b369
	dw $b505, $b505, $b370, $b696, $b1df, $b81d, $b052, $b99a, $aec8, $bb0c, $ad43, $bc75, $abc1, $bdd5, $aa43, $bf2c
	dw $fff6, $046a, $ffd9, $08d3, $ffa9, $0d39, $ff65, $119d, $ff0e, $15fd, $fea4, $1a58, $fe28, $1ead, $fd99, $22fb
	dw $fcf9, $2741, $fc47, $2b7f, $fb84, $2fb4, $fab1, $33de, $f9cd, $37fd, $f8da, $3c11, $f7d8, $4019, $f6c8, $4414
	dw $f5aa, $4801, $f47f, $4be1, $f347, $4fb2, $f204, $5374, $f0b5, $5727, $ef5c, $5acb, $edf9, $5e5e, $ec8c, $61e2
	dw $eb17, $6555, $e99a, $68b8, $e816, $6c0a, $e68b, $6f4c, $e4f9, $727d, $e362, $759d, $e1c6, $78ac, $e026, $7bab
	dw $de82, $7e99, $dcda, $8177, $db2f, $8444, $d982, $8701, $d7d3, $89ae, $d622, $8c4b, $d471, $8ed9, $d2be, $9157
	dw $d10b, $93c6, $cf58, $9626, $cda6, $9877, $cbf4, $9ab9, $ca43, $9ced, $c893, $9f14, $c6e5, $a12c, $c539, $a338
	dw $c38e, $a536, $c1e6, $a727, $c040, $a90c, $be9c, $aae4, $bcfb, $acb1, $bb5d, $ae71, $b9c2, $b027, $b82b, $b1d1
	dw $b696, $b370, $b505, $b505, $b377, $b68f, $b1ed, $b810, $b066, $b986, $aee3, $baf3, $ad64, $bc57, $abe9, $bdb1
	dw $fff7, $0457, $ffda, $08ac, $ffab, $0d00, $ff6a, $1151, $ff16, $159e, $feb0, $19e6, $fe38, $1e29, $fdae, $2266
	dw $fd13, $269b, $fc66, $2ac8, $fbaa, $2eec, $fadd, $3306, $fa01, $3716, $f915, $3b1b, $f81b, $3f14, $f713, $4301
	dw $f5fe, $46e1, $f4dc, $4ab4, $f3ad, $4e79, $f273, $5230, $f12e, $55d8, $efde, $5971, $ee84, $5cfb, $ed22, $6076
	dw $ebb6, $63e1, $ea43, $673c, $e8c8, $6a87, $e747, $6dc2, $e5bf, $70ed, $e432, $7408, $e29f, $7713, $e108, $7a0d
	dw $df6d, $7cf8, $ddce, $7fd2, $dc2d, $829d, $da88, $8557, $d8e1, $8803, $d739, $8a9e, $d58f, $8d2b, $d3e5, $8fa8
	dw $d239, $9217, $d08e, $9476, $cee2, $96c8, $cd37, $990b, $cb8d, $9b40, $c9e4, $9d68, $c83c, $9f82, $c695, $a18f
	dw $c4f0, $a38f, $c34d, $a582, $c1ac, $a76a, $c00e, $a944, $be72, $ab14, $bcd8, $acd7, $bb41, $ae8f, $b9ae, $b03d
	dw $b81d, $b1df, $b68f, $b377, $b505, $b505, $b37e, $b689, $b1fa, $b803, $b07a, $b973, $aefe, $badb, $ad84, $bc39
	dw $fff7, $0444, $ffdc, $0887, $ffae, $0cc9, $ff6f, $1107, $ff1e, $1542, $febb, $1979, $fe46, $1daa, $fdc1, $21d5
	dw $fd2b, $25fa, $fc84, $2a16, $fbce, $2e2a, $fb07, $3235, $fa32, $3635, $f94e, $3a2c, $f85b, $3e17, $f75b, $41f6
	dw $f64e, $45c9, $f534, $4990, $f40e, $4d49, $f2dd, $50f4, $f1a1, $5492, $f05a, $5821, $ef0a, $5ba2, $edb1, $5f13
	dw $ec4f, $6276, $eae5, $65ca, $e974, $690e, $e7fc, $6c42, $e67d, $6f67, $e4f9, $727d, $e370, $7582, $e1e2, $7878
	dw $e050, $7b5f, $deba, $7e36, $dd21, $80fe, $db85, $83b6, $d9e6, $865f, $d846, $88f9, $d6a4, $8b84, $d501, $8e01
	dw $d35d, $906f, $d1b9, $92ce, $d015, $9520, $ce71, $9764, $cccd, $999a, $cb2a, $9bc2, $c988, $9dde, $c7e7, $9fec
	dw $c648, $a1ee, $c4aa, $a3e3, $c30e, $a5cc, $c175, $a7aa, $bfdd, $a97b, $be49, $ab41, $bcb6, $acfc, $bb26, $aeac
	dw $b99a, $b052, $b810, $b1ed, $b689, $b37e, $b505, $b505, $b384, $b682, $b207, $b7f6, $b08d, $b961, $af17, $bac3
	dw $fff7, $0432, $ffdd, $0864, $ffb1, $0c93, $ff74, $10c0, $ff25, $14ea, $fec5, $190f, $fe55, $1d2f, $fdd4, $214a
	dw $fd42, $255e, $fca1, $296a, $fbf0, $2d6e, $fb30, $316a, $fa61, $355c, $f983, $3944, $f898, $3d21, $f7a0, $40f3
	dw $f69a, $44ba, $f589, $4874, $f46b, $4c21, $f342, $4fc2, $f20f, $5355, $f0d1, $56da, $ef8a, $5a51, $ee3a, $5dba
	dw $ece1, $6115, $eb80, $6461, $ea18, $679e, $e8a9, $6acb, $e734, $6dea, $e5b9, $70fa, $e438, $73fb, $e2b3, $76ed
	dw $e12a, $79cf, $df9c, $7ca3, $de0c, $7f67, $dc78, $821d, $dae2, $84c4, $d94a, $875c, $d7b0, $89e6, $d614, $8c61
	dw $d478, $8ece, $d2db, $912e, $d13d, $937f, $cfa0, $95c3, $ce02, $97f9, $cc66, $9a23, $caca, $9c3f, $c92f, $9e4f
	dw $c795, $a052, $c5fd, $a249, $c467, $a434, $c2d2, $a613, $c13f, $a7e7, $bfaf, $a9b0, $be21, $ab6d, $bc95, $ad20
	dw $bb0c, $aec8, $b986, $b066, $b803, $b1fa, $b682, $b384, $b505, $b505, $b38b, $b67c, $b214, $b7ea, $b0a0, $b94f
	dw $fff7, $0421, $ffde, $0841, $ffb3, $0c5f, $ff78, $107b, $ff2c, $1494, $fecf, $18a9, $fe62, $1cb9, $fde5, $20c3
	dw $fd58, $24c7, $fcbc, $28c3, $fc10, $2cb9, $fb56, $30a5, $fa8d, $3489, $f9b7, $3863, $f8d2, $3c33, $f7e1, $3ff8
	dw $f6e3, $43b2, $f5d9, $4760, $f4c4, $4b02, $f3a3, $4e98, $f278, $5220, $f143, $559c, $f004, $590a, $eebd, $5c6a
	dw $ed6d, $5fbc, $ec15, $6301, $eab6, $6636, $e950, $695e, $e7e3, $6c77, $e671, $6f81, $e4f9, $727d, $e37d, $756a
	dw $e1fc, $7848, $e077, $7b18, $deee, $7dd9, $dd63, $808c, $dbd5, $8330, $da44, $85c7, $d8b2, $884f, $d71e, $8ac9
	dw $d589, $8d35, $d3f2, $8f94, $d25c, $91e5, $d0c5, $9429, $cf2e, $9660, $cd98, $9889, $cc02, $9aa7, $ca6d, $9cb7
	dw $c8d9, $9ebc, $c746, $a0b4, $c5b5, $a2a1, $c425, $a482, $c297, $a658, $c10b, $a823, $bf82, $a9e3, $bdfa, $ab98
	dw $bc75, $ad43, $baf3, $aee3, $b973, $b07a, $b7f6, $b207, $b67c, $b38b, $b505, $b505, $b391, $b676, $b220, $b7df
	dw $fff8, $0410, $ffdf, $081f, $ffb6, $0c2d, $ff7c, $1039, $ff33, $1441, $fed9, $1845, $fe6f, $1c45, $fdf6, $2040
	dw $fd6d, $2434, $fcd6, $2822, $fc2f, $2c08, $fb7b, $2fe7, $fab8, $33bc, $f9e7, $3789, $f90a, $3b4b, $f820, $3f04
	dw $f729, $42b2, $f626, $4654, $f519, $49eb, $f400, $4d76, $f2dd, $50f4, $f1b0, $5466, $f07a, $57cb, $ef3b, $5b23
	dw $edf3, $5e6d, $eca4, $61a9, $eb4d, $64d8, $e9f0, $67f9, $e88c, $6b0b, $e722, $6e10, $e5b3, $7107, $e43f, $73ef
	dw $e2c6, $76c9, $e149, $7995, $dfc9, $7c53, $de45, $7f03, $dcbf, $81a5, $db36, $8439, $d9ab, $86bf, $d81e, $8938
	dw $d690, $8ba3, $d501, $8e01, $d371, $9051, $d1e1, $9295, $d051, $94cc, $cec1, $96f6, $cd31, $9914, $cba1, $9b26
	dw $ca13, $9d2b, $c886, $9f25, $c6fa, $a113, $c56f, $a2f6, $c3e6, $a4ce, $c25f, $a69a, $c0d9, $a85c, $bf56, $aa14
	dw $bdd5, $abc1, $bc57, $ad64, $badb, $aefe, $b961, $b08d, $b7ea, $b214, $b676, $b391, $b505, $b505, $b397, $b670
	dw $fff8, $0400, $ffe0, $07ff, $ffb8, $0bfd, $ff80, $0ff8, $ff39, $13f0, $fee2, $17e5, $fe7b, $1bd6, $fe06, $1fc1
	dw $fd81, $23a6, $fcee, $2785, $fc4d, $2b5d, $fb9e, $2f2e, $fae0, $32f6, $fa16, $36b5, $f93f, $3a6b, $f85b, $3e17
	dw $f76c, $41b9, $f670, $4550, $f56a, $48db, $f459, $4c5c, $f33e, $4fd0, $f219, $5338, $f0ea, $5694, $efb3, $59e3
	dw $ee74, $5d25, $ed2d, $605a, $ebdf, $6382, $ea89, $669c, $e92e, $69a9, $e7cc, $6ca8, $e665, $6f99, $e4f9, $727d
	dw $e389, $7552, $e214, $781b, $e09b, $7ad5, $df20, $7d82, $dda1, $8021, $dc1f, $82b3, $da9c, $8537, $d916, $87ae
	dw $d78f, $8a18, $d607, $8c75, $d47e, $8ec5, $d2f4, $9108, $d16a, $933f, $cfe0, $9569, $ce56, $9787, $cccd, $999a
	dw $cb44, $9ba0, $c9bc, $9d9b, $c835, $9f8a, $c6af, $a16f, $c52b, $a348, $c3a9, $a516, $c228, $a6da, $c0a9, $a894
	dw $bf2c, $aa43, $bdb1, $abe9, $bc39, $ad84, $bac3, $af17, $b94f, $b0a0, $b7df, $b220, $b670, $b397, $b505, $b505

NormalizeVector::
	; in: (bc, de): vector (signed, integer or any fixed point), a: target length (0 = $100)
	; out: (bc, de): normalized vector, multiplied by a, in 8.8 signed fixed point (a >= $80 might cause truncation)
	; preserves hl; returns (0, 0) and zero flag set if the input is the null vector
	push hl
	ld l, a
	ld a, b
	or c
	or d
	or e
	jp z, .done
	ld h, 0
	bit 7, b
	jr z, .handled_first_sign
	ld a, c
	cpl
	ld c, a
	ld a, b
	cpl
	ld b, a
	___safeinc bc
	set 1, h ; bit 1 = bc was negative
.handled_first_sign
	bit 7, d
	jr z, .handled_second_sign
	ld a, e
	cpl
	ld e, a
	ld a, d
	cpl
	ld d, a
	___safeinc de
	set 2, h ; bit 2 = de was negative
.handled_second_sign
	ld a, b
	or d
	jr nz, :+
	ld b, c
	ld d, e
	ld c, 0
	ld e, c

	:
	sla c
	rl b
	jr c, :+
	sla e
	rl d
	jr nc, :-
	inc h ; bit 0 = bc and de are swapped
	ld a, d
	ld d, b
	ld b, a
	ld a, e
	ld e, c
	ld c, a
	srl d
	rr e
	:

	push hl
	ld a, c
	or $3f
	ld c, a
	___safeinc bc
	ld a, e
	or $1f
	ld e, a
	___safeinc de
	ld a, b
	or c
	ld l, a
	ld a, d
	or e
	add a, $ff
	sbc a
	and l
	jr nz, .adjusted
	ld a, d
	or e
	sub 1
	rr d
	rr e
	ld a, b
	or c
	jr z, :+
	pop hl
	inc h
	push hl
	scf
	rr b
	rr c
	srl b
	rr c
	ld e, c
	ld d, b
	ld bc, 0
	:
	res 4, e

.adjusted
	ld a, b
	rlca
	swap a
	and $1f
	add a, HIGH(VectorNormalizationTables.unitvectors)
	ld h, a
	ld l, d
	set 1, l
	set 0, l

	ld a, b
	sla c
	rla
	and $f
	srl d
	rr e
	srl d
	rr e
	res 3, e
	or e
	ld e, a
	ld d, HIGH(VectorNormalizationTables.multiplication)
	ld a, [de]
	ld b, a
	ld a, e
	push af
	xor $f0
	add a, $10
	ld c, 0
	jr c, :+
	ld e, a
	ld a, [de]
	ld c, a
	:
	pop af
	ld e, a
	and $f
	jr z, :+
	ld a, e
	xor $f
	inc a
	push de
	ld e, a
	ld a, [de]
	pop de
	:
	push af

	ld a, e
	cpl
	add a, $11
	ld e, a
	ld a, 0
	daa
	jr z, :+
	ld e, 0
	:
	ld a, [de]
	pop de
	ld e, a

	push hl ; dummy
	push bc
	push de
	ld b, h
	ld c, l
	ld hl, sp - 1
	ld d, h
	ld e, l
	ld h, b
	ld l, c
	add sp, -6
	push hl
	ld a, [hld]
	ld [de], a
	dec de
	ld a, [hld]
	ld [de], a
	dec de
	ld a, [hld]
	ld b, a
	ld a, [hld]
	ld c, a
	push bc
	ld a, l
	inc a
	jr z, :+
	ld a, [hld]
	:
	ld [de], a
	dec de
	jr z, :+
	ld a, [hld]
	:
	ld [de], a
	dec de
	ld c, a
	jr z, :+
	ld a, [hld]
	ld c, [hl]
	:
	ld b, a
	push bc
	ld hl, sp + 4
	ld a, [hli]
	ld h, [hl]
	ld l, a
	inc h
	ld a, [hld]
	ld [de], a
	dec de
	ld a, [hld]
	ld [de], a
	dec de
	ld a, [hld]
	ld b, a
	ld a, [hld]
	ld c, a
	push bc
	ld a, l
	inc a
	jr z, :+
	ld a, [hld]
	:
	ld [de], a
	dec de
	jr z, :+
	ld a, [hld]
	:
	ld [de], a
	ld c, a
	jr z, :+
	ld a, [hld]
	ld c, [hl]
	:
	ld b, a

	ld hl, sp + 15
	ld e, [hl]
	or c
	ld a, 0
	jr nz, :+
	ld a, e
	inc hl
	inc hl
	add a, [hl]
	:
	ld hl, 0
	ld d, h
	___addproduct bc, e, d
	ld b, h
	ld c, l
	ld hl, sp + 14
	ld d, [hl]
	ld h, b
	ld l, c
	pop bc
	___addproduct bc, d, e
	ld b, h
	ld c, l
	ld hl, sp + 15
	ld e, [hl]
	inc e
	dec e
	jr nz, :+
	pop hl
	ld e, a
	ld a, l
	add a, b
	ld b, a
	ld a, e
	adc h
	jr .first_skip
	:
	ld h, b
	ld l, c
	pop bc
	___addproduct bc, e, d
	ld b, h
	ld c, l
.first_skip
	ld hl, sp + 12
	ld d, [hl]
	ld h, b
	ld l, c
	pop bc
	___addproduct bc, d, e
	ld e, $80
	add hl, de
	adc d
	ld c, h
	ld b, a
	ld hl, sp + 14
	ld e, [hl]
	inc e
	dec e
	jr z, .first_zero
	xor a
	ld h, a
	ld l, a
	___addproduct bc, e, d
	ld de, $80
	add hl, de
	adc d
	ld c, h
	ld b, a
.first_zero
	ld hl, sp + 13
	ld [hld], a
	ld [hl], c

	ld hl, sp + 9
	ld e, [hl]
	xor a
	ld h, a
	ld l, a
	ld d, a
	pop bc
	___addproduct bc, e, d
	ld b, h
	ld c, l
	ld hl, sp + 6
	ld d, [hl]
	ld h, b
	ld l, c
	pop bc
	___addproduct bc, d, e
	ld b, h
	ld c, l
	ld hl, sp + 7
	ld e, [hl]
	inc e
	dec e
	jr nz, :+
	pop hl
	ld e, a
	ld a, l
	add a, b
	ld b, a
	ld a, e
	adc h
	jr .second_skip
	:
	ld h, b
	ld l, c
	pop bc
	___addproduct bc, e, d
	ld b, h
	ld c, l
.second_skip
	ld hl, sp + 4
	ld d, [hl]
	ld h, b
	ld l, c
	pop bc
	___addproduct bc, d, e
	ld e, $80
	add hl, de
	adc d
	ld c, h
	ld b, a
	ld hl, sp + 6
	ld e, [hl]
	inc e
	dec e
	ld a, b
	jr z, .second_zero
	xor a
	ld h, a
	ld l, a
	___addproduct bc, e, d
	ld de, $80
	add hl, de
	adc d
	ld c, h
	ld b, a
.second_zero

	add sp, 4
	pop de
	pop hl
	ld a, d
	or e
	jr nz, :+
	ld d, l
	:
	srl h
	jr c, :+
	ld a, b
	ld b, d
	ld d, a
	ld a, c
	ld c, e
	ld e, a
	:
	srl h
	jr nc, .first_positive
	ld a, b
	cpl
	ld b, a
	ld a, c
	cpl
	ld c, a
	___safeinc bc
.first_positive
	srl h
	jr nc, .second_positive
	ld a, d
	cpl
	ld d, a
	ld a, e
	cpl
	ld e, a
	___safeinc de
.second_positive
	rra ; clear zero flag
.done
	pop hl
	ret

	PURGE ___safeinc, ___addproduct
