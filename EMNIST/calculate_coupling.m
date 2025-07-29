function coupling = calculate_coupling(patterns)
%this function calculates the coupling strength coefficients for the PSK
%approach, given the frequency dispersion value sigma

    K = size(patterns, 2); %find the number of memorized patterns
    N = size(patterns, 1); %find the number of elements in an array
    P = zeros(N); %preallocate the P matrix
    for k = 1:K
       for l = 1:N
           P(l, k) = patterns(l, k);
       end
    end
    P_dagger = pinv(P); %find its pseudoinverse
    coupling_strength = 0.25; %set the coupling strength
    coupling = coupling_strength*(P*P_dagger); %Find the idealised coupling matrix

end