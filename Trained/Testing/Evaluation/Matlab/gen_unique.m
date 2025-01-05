function a = gen_unique(imin, imax, val)
    a = randi([imin, imax], 1);
    if a == val
        a = gen_unique(imin, imax, a);
    end
end
    