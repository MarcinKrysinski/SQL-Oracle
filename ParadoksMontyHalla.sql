DECLARE
    removed_box      INTEGER;
    user_choice_new  INTEGER;
    prize            VARCHAR2(1);
BEGIN
    FOR i IN (SELECT id,correct_box,user_choice,change_decision FROM game_options) 
    LOOP
        --prowadzacy usuwa jedna bramke
        LOOP
           -- DBMS_OUTPUT.PUT_LINE (i.id);
            removed_box := round(dbms_random.value(1, 3));
            IF
                removed_box <> i.correct_box
                AND removed_box <> i.user_choice
            THEN
                EXIT;
            END IF;

        END LOOP;
       
       --czy uzytkownik zmienil decyzje

        IF i.change_decision = 'T' THEN
            IF
                1 <> removed_box AND 1 <> i.user_choice THEN
                user_choice_new := 1;
            ELSIF
                2 <> removed_box AND 2 <> i.user_choice THEN
                user_choice_new := 2;
            ELSE
                user_choice_new := 3;
            END IF;

        ELSE
            user_choice_new := i.user_choice;
        END IF;

        IF user_choice_new = i.correct_box THEN
            prize := 'Y';
        ELSE
            prize := 'N';
        END IF;
        
        -- zapisz wyniki
                     INSERT INTO game_scores(option_id, user_choice_new, removed_box, prize) 
                          VALUES (i.id, user_choice_new, removed_box, prize);
        dbms_output.put_line(i.id || ', '|| i.change_decision|| ', '|| i.user_choice|| ', '|| user_choice_new||', '||i.correct_box||', '||prize);

    END LOOP;
END;


-- obliczenie szans na zwycięstwo
      SELECT GO.change_decision
                    , SUM(CASE 
                                   WHEN gs.prize = 'Y' THEN 1
                                   ELSE 0
                                END
                               ) score
      FROM game_scores gs
      INNER JOIN game_options go
                           ON GS.option_id = go.id
      GROUP BY go.change_decision;