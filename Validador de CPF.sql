CREATE OR REPLACE PROCEDURE pcd_validador_cpf(pnr_cpf IN VARCHAR2) IS
pRetorno				BOOLEAN;
vCpf                    t_mc_cli_fisica.nr_cpf%TYPE;
vCpf_desmembrado        t_mc_cli_fisica.nr_cpf%TYPE;
vDigito_verificador_1   NUMBER;
vDigito_verificador_2   NUMBER;
vMultiplicador          NUMBER;
vSoma                   NUMBER;
vResto_digito_1         NUMBER;
vResto_digito_2         NUMBER;

FUNCTION fc_validador_cpf(pnr_cpf IN VARCHAR2) RETURN BOOLEAN
IS
BEGIN
vCpf := pnr_cpf;

    vCpf_desmembrado 	  := LPAD(to_char(vCpf), 11, '0');
    vDigito_verificador_1 := to_number(substr(vCpf_desmembrado,10,1));
    vDigito_verificador_2 := to_number(substr(vCpf_desmembrado,11,1));

    /* Calculo do primeiro digito */
        vMultiplicador := 10;
        vSoma := 0;
        for i in 1..9
    loop
        vSoma := vSoma + (to_number(substr(vCpf_desmembrado,i,1)) * vMultiplicador);
        vMultiplicador := vMultiplicador - 1;    
    end loop;
        vResto_digito_1 := mod(vSoma * 10,11);
  
    if vResto_digito_1 = 10 then
        vResto_digito_2 := 0;
    end if;

    /* Calculo do segundo digito */
        vMultiplicador := 11;
        vSoma := 0;
        for i in 1..10
    loop
    
        vSoma := vSoma + (to_number(substr(vCpf_desmembrado,i,1)) * vMultiplicador);
        vMultiplicador := vMultiplicador - 1;    
    end loop;
        vResto_digito_2 := mod(vSoma * 10,11);
    if vResto_digito_2 = 10 then
        vResto_digito_2 := 0;
    end if;

    /* Verificação dos digitos */
    if (vResto_digito_1 = vDigito_verificador_1) AND ( vResto_digito_2 = vDigito_verificador_2)
        THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
 		END IF;  
	END;
BEGIN
	IF TO_NUMBER(pnr_cpf) = 0 THEN
		raise_application_error(-20011, 'O número do CPF Indicado é zero! Corrija e tente novamente!');
	ELSE 
		pRetorno := fc_validador_cpf(pnr_cpf);
		IF pRetorno = FALSE THEN
			raise_application_error(-20010, 'O CPF INSERIDO: ' || TO_CHAR(pnr_cpf) || ' - É INVÁLIDO!');
		ELSE IF pRetorno = TRUE THEN
			DBMS_OUTPUT.PUT_LINE('O CPF INSERIDO: '|| TO_CHAR(pnr_cpf) || ' - É VALIDO!');
		ELSE
			DBMS_OUTPUT.PUT_LINE('ERRO!');
		END IF;
	END IF;
END IF;

EXCEPTION 
WHEN OTHERS THEN RAISE;
END;
/

/* EXECUTE do procedimento
EXECUTE PCD_VALIDADOR_CPF(31848093586); - numero valido.

EXECUTE PCD_VALIDADOR_CPF(12345678914); - numero invalido.

EXECUTE PCD_VALIDADOR_CPF(0); - zero.

*/