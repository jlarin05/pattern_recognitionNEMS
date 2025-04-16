function [t, output] = PSK(amplitudes, etalon, d, sigma)    
%This function returns the final state of a network of Duffing oscillators,
%given its initial state, as well as values of frequency (d) and coupling
%strength (sigma) dispersions


    %Set up the coupling matrix--------------------------------------------
    global coupling
    calculate_coupling(sigma);

    N = numel(amplitudes); %Number of oscillators in a network
    

    %Set the nonlinearlity of the Duffing oscillator-----------------------
    global lambda
    lambda = 0.35;


    %Calculate the frequency dispersion of each oscillator-----------------
    omega_0 = 100; %This is the desired frequency
    omega = zeros(N, 1); %an array of oscillator frequencies is found
    a = omega_0 - d;
    b = omega_0 + d;
    for m = 1:N
        omega(m) = (b - a)*rand() + a; %each oscillator is assigned a random frequency from the interval omega_0 +- d
    end
    delta = (omega/omega_0).^2 - 1; %frequency dispersion is calculated
    %----------------------------------------------------------------------
    
    %Calculate the time evolution of the oscillator network----------------
    options = odeset('AbsTol', 10^-6);
    [t, x] = ode89(@Duff, [0 500], amplitudes, options);
    output = x(end, :);


    %Find the degree of match between the network output and the nearest
    %memorized pattern
    
    
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
            dxdt(k) = contribution - 0.5*x(k) + 0.25*x(k)/(abs(x(k))) + lambda*((abs(x(k)))^2)*x(k)*1i + delta(k)*0.5i;
    
        end
    end
end
