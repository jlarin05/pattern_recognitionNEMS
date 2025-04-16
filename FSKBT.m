function [t, amp] = FSKBT(test, pattern, overlap, extra, d, s)    
%This function returns the state of an initially-synchronized oscillator
%layer with all-to-all coupling, given the pattern memorized by the layer, the input pattern,
%frequency dispersion and coupling strength dispersion
    

    %Set the nonlinearlity of the Duffing oscillator-----------------------
    global lambda
    lambda = 0.35;

    
    %Set the number of oscillators in a network
    N = numel(test);
    

    %Calculate the oscillator's frequencies--------------------------------
    omega_0 = 100;
    omega = omega_0*ones(N, 1);
    delta_omega = 20;
    for m = 1:N
        omega(m) = omega(m) + delta_omega*(test(m) - pattern(m)) + extra*overlap(m)*(test(m) - pattern(m)) + d*(2*rand() - 1); %the first term is the input frequency shift; 
        %the second is frequency dispersion due to the imperfections in the
        %oscillators
    end
    delta = (omega/omega_0).^2 - 1;
    %----------------------------------------------------------------------
    global rho

    rho_naught = 0.5;
    rho = rho_naught*ones(1, N); %set the coupling strength


    for l = 1:N
        sigma = s*rho_naught; %take coupling strength dispersion into account
        rho(l) = rho(l) + sigma*(2*rand() - 1);
    end
    

    %Calculate the time evolution of the oscilltor network-----------------
    options = odeset('AbsTol', 10^-6);
    [t, x] = ode45(@Duff, [0 200], ones(96, 1), options);

    amp = abs(mean(x'));
    
    %Simulate the network web--------------------------------------------------
    function dxdt =  Duff(t, x)
    %The differential equation for the oscillator's amplitude    
        dxdt = zeros(N, 1); %preallocate oscillator velocities


        %In the FSKAAC, the output signal of all oscillators is averaged
        %and 'fed' back into the oscillators
        %Below, the average output is calculated
        average = 0;
        for k = 1:N
            average = average + rho(k)*x(k);
        end
        average = average/N; 


        for k = 1:N %k&l were chosen to avoid confusion with the imaginary unit i/j

            dxdt(k) = -0.5*x(k) + 0.25*x(k)/(abs(x(k))) + lambda*((abs(x(k)))^2)*x(k)*1i + rho(k)*average + delta(k)*0.5i;    
        end
        
    end

end
