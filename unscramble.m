function uns_vec = unscramble(scr_v)
    uns_vec = scr_v * 0;
    for i = 1:length(scr_v)
       uns_vec(i) = find(scr_v == i , 1);
    end
end
