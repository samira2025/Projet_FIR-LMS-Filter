%%==============================================================================================
%    UNIVERSITÉ DU QUÉBEC A TROIS-RIVIERES
%    Département de génie électrique et de génie informatique
%    COURS: GEI-1064 Conception en VLSI
%    Date: Automne 2023
%%=============================================================================================
clear all;  % Effacement des memoires des toutes les memoires et fonctions
close all;  % On ferme toutes les figures en cours
clc;        % Effacement des commandes precedement tappees dans la Command Window
seed = 1; randn('state', seed); %-- pour avoir toujours la même séquence aléatoire

%-- PAramètres ------------------------------------------------------------
Nseq = 100;
N_Bit = 8;
%%=========================================================================
% VIRGULE FLOTTANTE (précision maximale)
%%=========================================================================
xin =0.2*randn(Nseq,1);
w1 =0.2*randn(Nseq,1);
w2 =0.2*randn(Nseq,1);
w3 =0.2*randn(Nseq,1);
w4 =0.2*randn(Nseq,1);
w5 =0.2*randn(Nseq,1);

%%=========================================================================
% FIR ==> VIRGULE FIXE (précision limitée par le nb. de bit)
%=========================================================================
%-- Conversion des entrées en décimale représentable en binaire
for n=1:Nseq
    xin_fix(n,2)=Quantize_func(xin(n,1),N_Bit);
    w1_fix(n,2)=Quantize_func(w1(n,1),N_Bit);
    w2_fix(n,2)=Quantize_func(w2(n,1),N_Bit);
    w3_fix(n,2)=Quantize_func(w3(n,1),N_Bit);
    w4_fix(n,2)=Quantize_func(w4(n,1),N_Bit);
    w5_fix(n,2)=Quantize_func(w5(n,1),N_Bit);
end

%-- Formattage des données pour Simulink
time = 0:1/20e6:1/20e6*100-1/20e6;
xin_fix(:,1) = time;
w1_fix(:,1) = time;
w2_fix(:,1) = time;
w3_fix(:,1) = time;
w4_fix(:,1) = time;
w5_fix(:,1) = time;

%-- Mise sous-forme matricielle de l'entrée Yin
xin_fix_mat = [xin_fix(:,2) [0;xin_fix(1:end-1,2)] [0;0;xin_fix(1:end-2,2)] [0;0;0;xin_fix(1:end-3,2)] [0;0;0;0;xin_fix(1:end-4,2)]];

%--> Quantification des signaux A et B -----------------------
for n=1:Nseq
    prod1(n,1) = xin_fix_mat(n,1)*w1_fix(n,2);   % à chaque clk, les w sont changés eux-aussi
    prod2(n,1) = xin_fix_mat(n,2)*w2_fix(n,2);
    prod3(n,1) = xin_fix_mat(n,3)*w3_fix(n,2);
    prod4(n,1) = xin_fix_mat(n,4)*w4_fix(n,2);  
    prod5(n,1) = xin_fix_mat(n,5)*w5_fix(n,2);
    
    prod1_fix(n,1) = Quantize_func(prod1(n,1),2*N_Bit);
    prod2_fix(n,1) = Quantize_func(prod2(n,1),2*N_Bit);
    prod3_fix(n,1) = Quantize_func(prod3(n,1),2*N_Bit);
    prod4_fix(n,1) = Quantize_func(prod4(n,1),2*N_Bit);
    prod5_fix(n,1) = Quantize_func(prod5(n,1),2*N_Bit);
    
    Sout_part1(n,1) = prod1_fix(n,1)+ prod2_fix(n,1);
    Sout_part1_fix(n,1) =Quantize_func(Sout_part1(n,1),2*N_Bit);
    
    Sout_part2(n,1) = Sout_part1_fix(n,1)+ prod3_fix(n,1);
    Sout_part2_fix(n,1) =Quantize_func(Sout_part2(n,1),2*N_Bit);
    
    Sout_part3(n,1) = Sout_part2_fix(n,1)+ prod4_fix(n,1);
    Sout_part3_fix(n,1) =Quantize_func(Sout_part3(n,1),2*N_Bit);
    
    Sout(n,1) = Sout_part3_fix(n,1) + prod5_fix(n,1);
    Sout_fix(n,2) = Quantize_func(Sout(n,1),2*N_Bit);
end
Sout_fix(:,1) = time;


%END PART 1
%% =========================================================================
%START PART 2

%==========================================================================
% Courbes de comparaisons
%==========================================================================

%=== Comparaison des résultats VHDL et MATLAB =============================

figure;
plot(out.Out_sysgen(1:end-1),'o-b')
hold on
plot(Sout_fix(:,2),'*-r')
hold off
legend('S Sysgen','S Matlab')
xlabel('Échantillons')
ylabel( 'Amplitudes')
title('FIR - Sortie Sysgen et Matlab')
axis([1 length(Sout_fix) -0.35 0.35])