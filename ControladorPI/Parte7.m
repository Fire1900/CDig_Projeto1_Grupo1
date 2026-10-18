% ==============================================================================
% PASSO 7 - SIMULAÇÃO E VALIDAÇÃO NO SIMULINK COM ANTI-WINDUP DISCRETO (GRUPO 1)
% ==============================================================================
clear; clc; close all;

%% 1. Parâmetros Identificados do Modelo P2DZ (Grupo 1)
Kp  = 0.1239;     % Ganho estático do processo (ºC / PWM)
Tp1 = 449.04;    % Constante de tempo LENTA (ambiente) em segundos
Tp2 = 31.96;     % Constante de tempo RÁPIDA (aquecimento) em segundos
Tz  = 367.32;    % Zero térmico em segundos
Td  = 6.67;      % Atraso de transporte (tempo morto) em segundos
Ta  = 23.5;        % Temperatura Ambiente medida (ºC)
PO  = 45;        % Ponto de Operação do Grupo 1 (ºC)

%% 2. Parâmetros da Perturbação do Cooler (Grupo 1)
w0    = 0.06544984694979; % Frequência da perturbação do cooler (rad/s)
AmpW0 = 0.02;             % Amplitude da perturbação

%% 3. Decomposição Modal em Frações Parciais (Bloco 'Processo Térmico')
Am = (Tz - Tp1) / (Tp2 - Tp1); % Peso do modo lento Tp1 (Am = 0.1959)
Bm = 1 - Am;                   % Peso do modo rápido Tp2 (Bm = 0.8041)

%% 4. Período de Amostragem Discreto (Ts = Td / 2)
Ts = Td / 2;                   % Ts = 3.335 s

%% 5. Ganhos do Controlador PI Discreto (Projetado no Passo 6)
K_z  = 30.89;                  % Ganho do PI em z
z_pi = 0.942;                  % Zero do PI em z

% Conversão para os blocos Gain do Simulink (KP e KI):
KP = K_z;                      % Ganho Proporcional (KP = 30.89)
KI = K_z * (1 - z_pi) / Ts;    % Ganho Integral Discreto (KI ≈ 0.5372)

%% 6. Execução Automática das Simulações no Simulink (Prj1CDig.slx)
open Prj1CDig_Discrete;

% --- FASE 1: Simulação SEM Anti-Windup (sw = 1) ---
disp('1. Executando simulação SEM Anti-Windup (sw = 1)...');
set_param('Prj1CDig_Discrete/Anti-WindUp', 'sw', '1');
sim('Prj1CDig_Discrete');
disp('   Simulação SEM Anti-Windup concluída!');
disp('   Observe no Scope o acúmulo de erro (windup) e o sobrepasso elevado.');
fprintf('\n---> Pressione <ENTER> no Command Window para rodar COM Anti-Windup...\n');
pause;

% --- FASE 2: Simulação COM Anti-Windup (sw = 0) ---
disp('2. Executando simulação COM Anti-Windup (sw = 0)...');
set_param('Prj1CDig_Discrete/Anti-WindUp', 'sw', '0');
sim('Prj1CDig_Discrete');
disp('   Simulação COM Anti-Windup concluída com sucesso!');