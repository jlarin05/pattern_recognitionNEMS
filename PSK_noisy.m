function [t, output] = PSK_noisy(amplitudes, etalon, epsilon) 
%This function returns the state of a network of Duffing oscillators,
%given the pattern memorized by the layer given its initial state
%and noise levels. Frequency dispersion and coupling strength dispersion
%can additionally be specified in the function body


%!!!NB: THIS CODE REQUIRES AN SDE EQUATION SOLVER!!! 
%IT IS AVAILABLE AT: https://github.com/horchler/SDETools?tab=readme-ov-file


    %Set up the coupling matrix--------------------------------------------
    global coupling
    calculate_coupling(0);

    N = numel(amplitudes); %calculate the size of the network
    
    %Set the nonlinearlity of the Duffing oscillator-----------------------
    global lambda
    lambda = 0.35;

    dt = 1e-2;
    t = 0:dt:500;
    g = @(t, x)epsilon;
    omega_0 = 100;
    omega = zeros(N, 1);

    d = 0;
    a = omega_0 - d;
    b = omega_0 + d;
    for m = 1:N
        omega(m) = (b - a)*rand() + a;
    end

    delta = (omega/omega_0).^2 - 1;
    %--------------------------------------------------------------------------
    
    %Calculate the time evolution of the oscillator network--------------------
    x = sde_euler(@Duff, g, t, amplitudes);


    output = x(end, :);

    
    
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
