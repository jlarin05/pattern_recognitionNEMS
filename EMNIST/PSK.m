function DoM = PSK(amplitudes, etalon, coupling)    
%This function returns the final state of a network of Duffing oscillators,
%given its initial state, as well as values of frequency (d) and coupling
%strength (sigma) dispersions


    %Set up the coupling matrix--------------------------------------------
    

    N = numel(amplitudes); %Number of oscillators in a network
    

    %Set the nonlinearlity of the Duffing oscillator-----------------------
    global lambda
    lambda = 0.35;

    %----------------------------------------------------------------------
    
    %Calculate the time evolution of the oscillator network----------------
    options = odeset('AbsTol', 10^-6);
    [t, x] = ode89(@Duff, [0 100], amplitudes, options);


    %Find the degree of match between the network output and the nearest
    %memorized pattern
    T = numel(t);
    DoM = zeros(T, 1);    
    for n = 1:T
        output = x(n, :); %the network output is normalised before calculating the degree of match
        factor = 1/output(1);
        output = factor*output;
        normalised_output = exp(angle(output)*1i);
        DoM(n) = abs(degree_of_match(normalised_output, etalon/etalon(1)));
    end
    DoM = DoM(end);

    
    %Simulate the network web----------------------------------------------
    function dxdt =  Duff(t, x)
        dxdt = zeros(N, 1);
        for k = 1:N %k&l were chosen to avoid confusion with the imaginary unit i/j


            %first calculate the contribution from other oscillators-------
            contribution = 0;
            for l = 1:N
               contribution = contribution + coupling(k, l)*x(l);
            end


            %Then, find the velocity of the k-th oscillator
            dxdt(k) = contribution - 0.5*x(k) + 0.25*x(k)/(abs(x(k))) + lambda*((abs(x(k)))^2)*x(k)*1i;
    
        end
    end
end
