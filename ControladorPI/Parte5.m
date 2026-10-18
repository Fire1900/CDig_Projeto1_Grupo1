% ==============================================================================
% PASSO 5: VALIDAÇÃO DO PI CONTÍNUO NO SIMULINK COM ANTI-WINDUP (GRUPO 1)
% ==============================================================================
clear; clc; close all;

%% 1. Parâmetros Físicos Identificados (Modelo P2DZ - Grupo 1)
% Convenção do Roteiro: Tp1 = Lento (ambiente), Tp2 = Rápido (aquecimento)
Kp  = 0.1239;     % Ganho estático do processo (ºC / PWM)
Tp1 = 449.04;    % Constante de tempo LENTA (ambiente) em segundos
Tp2 = 31.96;     % Constante de tempo RÁPIDA (aquecimento) em segundos
Tz  = 367.32;    % Zero térmico em segundos
Td  = 6.67;      % Atraso de transporte (tempo morto) em segundos
Ta  = 23.5;        % Temperatura Ambiente (ºC)
PO  = 45;        % Ponto de Operação do Grupo 1 (ºC)

%% 2. Parâmetros da Perturbação do Cooler (Grupo 1)
w0    = 0.06544984694979; % Frequência da perturbação do cooler (rad/s)
AmpW0 = 0.02;             % Amplitude da perturbação

%% 3. Decomposição Modal em Frações Parciais (Bloco 'Processo Térmico')
Am = (Tz - Tp1) / (Tp2 - Tp1); % Peso do modo lento Tp1 (Am = 0.1959)
Bm = 1 - Am;                   % Peso do modo rápido Tp2 (Bm = 0.8041)

%% 4. Ganhos do Controlador PI Contínuo (Ajustados no Passo 4 / SISOTOOL)
KP = 33.2;                     % Ganho Proporcional
KI = KP / Tp2;                 % Ganho Integral (KI = 1.0388 - cancela Tp2)

%% 5. Período de Amostragem do Controle Digital (Ts = Td / 2)
Ts = Td / 2;                   % Ts = 3.335 s

%% 6. Exibição dos Parâmetros no Command Window
fprintf('====================================================\n');
fprintf('     PARÂMETROS CARREGADOS NA WORKSPACE (GRUPO 1)   \n');
fprintf('====================================================\n');
fprintf('Ponto de Operação (PO) : %d ºC\n', PO);
fprintf('Temperatura Ambiente (Ta): %d ºC\n', Ta);
fprintf('Decomposição Modal       : Am = %.4f | Bm = %.4f\n', Am, Bm);
fprintf('Ganhos do PI Contínuo    : KP = %.2f  | KI = %.4f\n', KP, KI);
fprintf('====================================================\n\n');

%% 7. Execução Automática das Simulações no Simulink (Prj1CDig.slx)
if exist('Prj1CDig', 'file') == 4
    open Prj1CDig;

    % --- FASE 1: Simulação SEM Anti-Windup (sw = 1) ---
    disp('1. Executando simulação SEM Anti-Windup (sw = 1)...');
    set_param('Prj1CDig/Anti-WindUp', 'sw', '1');
    sim('Prj1CDig');
    disp('   Simulação SEM Anti-Windup concluída!');
    disp('   Observe no Scope o acúmulo de erro (windup) e o sobrepasso elevado.');
    fprintf('\n---> Pressione <ENTER> no Command Window para rodar COM Anti-Windup...\n');
    pause;

    % --- FASE 2: Simulação COM Anti-Windup (sw = 0) ---
    disp('2. Executando simulação COM Anti-Windup (sw = 0)...');
    set_param('Prj1CDig/Anti-WindUp', 'sw', '0');
    sim('Prj1CDig');
    disp('   Simulação COM Anti-Windup concluída com sucesso!');
    disp('   Anote o valor do ISE exibido no visor do Simulink para o relatório.');
else
    disp('Aviso: O arquivo Prj1CDig.slx não foi encontrado na pasta atual.');
    disp('Garantas que o arquivo do Simulink esteja no mesmo diretório do script.');
end