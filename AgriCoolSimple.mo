within ;
package AgriCoolSimple "AGRI-COOL training: off-grid cold room with PV chiller and ice storage"
  extends Modelica.Icons.Package;
  import SI = Modelica.Units.SI;

  record Design "Main design and scenario data - edit here"
    extends Modelica.Icons.Record;
    // Scenario
    parameter Real loadingHour(min = 0, max = 23.9) = 16 "Daily crop loading time [h]" annotation(
      Dialog(group = "Scenario"));
    parameter Real solarFactor(min = 0, max = 1) = 1 "Irradiance factor on normal days" annotation(
      Dialog(group = "Scenario"));
    parameter Real solarFactorCloudy(min = 0, max = 1) = 1 "Irradiance factor during the cloudy period (1 = no cloud)" annotation(
      Dialog(group = "Scenario"));
    parameter SI.Time tCloudyStart = 86400 "Start of cloudy period (default: start of day 2)" annotation(
      Dialog(group = "Scenario"));
    parameter SI.Time tCloudyEnd = 172800 "End of cloudy period (default: end of day 2)" annotation(
      Dialog(group = "Scenario"));
    // Cold room
    parameter SI.Temperature TSet = 279.15 "Room setpoint" annotation(
      Dialog(group = "Cold room"));
    parameter SI.Volume VRoom = 48 "Room air volume" annotation(
      Dialog(group = "Cold room"));
    parameter SI.ThermalConductance UARoom = 20 "Envelope UA (insulation)" annotation(
      Dialog(group = "Cold room"));
    parameter SI.HeatCapacity CRoom = 1.5e6 "Envelope heat capacity" annotation(
      Dialog(group = "Cold room"));
    parameter SI.Temperature TRoom_start = 283.15 "Initial room temperature" annotation(
      Dialog(group = "Cold room"));
    // Crops
    parameter SI.Mass mCrop = 500 "Crop mass per daily batch" annotation(
      Dialog(group = "Crops"));
    parameter SI.SpecificHeatCapacity cpCrop = 3500 "Crop specific heat" annotation(
      Dialog(group = "Crops"));
    parameter SI.Temperature TCropArrival = 293.15 "Crop temperature at loading" annotation(
      Dialog(group = "Crops"));
    parameter SI.ThermalConductance GCrop = 100 "Crop-to-air heat transfer" annotation(
      Dialog(group = "Crops"));
    parameter Real storageHours(min = 0.5, max = 23.9) = 17 "Time each batch stays in the room [h]" annotation(
      Dialog(group = "Crops"));
    // PV
    parameter Integer nPV = 10 "Number of modules" annotation(
      Dialog(group = "PV"));
    parameter SI.Area APV = 1.63 "Area of one module" annotation(
      Dialog(group = "PV"));
    parameter Real etaPV = 0.14 "Module efficiency" annotation(
      Dialog(group = "PV"));
    parameter Real fActPV = 0.89 "Active area fraction" annotation(
      Dialog(group = "PV"));
    // Chiller
    parameter SI.Power PChi_nominal = 2000 "Compressor power at full load" annotation(
      Dialog(group = "Chiller"));
    parameter Real COP_nominal = 2 "COP at -5 degC brine, 40 degC condenser" annotation(
      Dialog(group = "Chiller"));
    parameter SI.Temperature TChiMin = 268.15 "Lowest brine outlet temperature" annotation(
      Dialog(group = "Chiller"));
    parameter SI.Power PStart = 475 "Chiller starts above this PV power" annotation(
      Dialog(group = "Chiller"));
    parameter SI.Power PStop = 375 "Chiller stops below this PV power" annotation(
      Dialog(group = "Chiller"));
    // Ice storage
    parameter SI.Mass mIce = 218 "Ice storage capacity" annotation(
      Dialog(group = "Ice storage"));
    parameter Real SOC_start(min = 0.01, max = 0.99) = 0.99 "Initial state of charge (keep between 0 and 1)" annotation(
      Dialog(group = "Ice storage"));
    // Brine and air loops
    parameter SI.MassFlowRate mBrine = 0.41 "Brine flow (pump, constant)" annotation(
      Dialog(group = "Brine and air loops"));
    parameter SI.MassFlowRate mAir = 0.35 "Fan air flow at full speed" annotation(
      Dialog(group = "Brine and air loops"));
    parameter Real epsCoil = 0.33 "Fan-coil effectiveness" annotation(
      Dialog(group = "Brine and air loops"));
    parameter Real yFanMin(min = 0.01, max = 1) = 0.05 "Minimum fan speed" annotation(
      Dialog(group = "Brine and air loops"));
    annotation(
      defaultComponentName = "design",
      defaultComponentPrefixes = "parameter",
      Icon(graphics = {Rectangle(extent = {{-100, 100}, {100, -100}}, lineColor = {33, 84, 115}, fillColor = {235, 246, 251}, fillPattern = FillPattern.Solid, radius = 10), Text(extent = {{-95, 65}, {95, 20}}, textString = "DESIGN", textColor = {33, 84, 115}), Text(extent = {{-95, 0}, {95, -65}}, textString = "Double-click\nto edit", textColor = {33, 84, 115})}),
      Documentation(info = "<html><p>All main design and scenario values in one place. Double-click <b>design</b> in the diagram, change a value, simulate again.</p></html>"));
  end Design;

  package Media "Fluids"
    extends Modelica.Icons.MaterialPropertiesPackage;
    package Air = Buildings.Media.Air;
    package Brine = Buildings.Media.Antifreeze.PropyleneGlycolWater(property_T = 273.15, X_a = 0.40) "40 % propylene glycol";
  end Media;

  package Components "Simple components used in the system model"
    extends Modelica.Icons.Package;

    model ColdRoom "Cold room: well-mixed air and one envelope layer"
      parameter SI.Volume V = 48 "Room air volume";
      parameter SI.ThermalConductance UA = 20 "Envelope UA";
      parameter SI.HeatCapacity CWall = 1.5e6 "Envelope heat capacity";
      parameter SI.MassFlowRate mAir_nominal = 0.35;
      parameter SI.Temperature T_start = 283.15;
      parameter SI.Temperature TWall_start = 291.15;
      Modelica.Fluid.Interfaces.FluidPort_a supply(redeclare package Medium = Media.Air) "Cold air in" annotation(
        Placement(transformation(extent = {{-110, -10}, {-90, 10}})));
      Modelica.Fluid.Interfaces.FluidPort_b returnAir(redeclare package Medium = Media.Air) "Room air out" annotation(
        Placement(transformation(extent = {{90, -10}, {110, 10}})));
      Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a heatPort "Internal heat gains" annotation(
        Placement(transformation(extent = {{-10, -110}, {10, -90}})));
      Modelica.Blocks.Interfaces.RealInput TAmb(unit = "K") "Outdoor temperature" annotation(
        Placement(transformation(origin = {0, 110}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
      Modelica.Blocks.Interfaces.RealOutput T(unit = "K") "Room air temperature" annotation(
        Placement(transformation(extent = {{100, 50}, {120, 70}})));
      Buildings.Fluid.MixingVolumes.MixingVolume air(redeclare package Medium = Media.Air, V = V, nPorts = 3, m_flow_nominal = mAir_nominal, mSenFac = 1, energyDynamics = Modelica.Fluid.Types.Dynamics.FixedInitial, massDynamics = Modelica.Fluid.Types.Dynamics.SteadyState, T_start = T_start, p_start = 101325) annotation(
        Placement(transformation(extent = {{30, -20}, {70, 20}})));
      Buildings.Fluid.Sources.Boundary_pT pressureReference(redeclare package Medium = Media.Air, nPorts = 1, p = 101325, T = T_start) annotation(
        Placement(transformation(extent = {{30, -80}, {50, -60}})));
      Modelica.Thermal.HeatTransfer.Sources.PrescribedTemperature ambient annotation(
        Placement(transformation(extent = {{-90, 20}, {-70, 40}})));
      Modelica.Thermal.HeatTransfer.Components.ThermalResistor ROut(R = 0.5/UA) annotation(
        Placement(transformation(extent = {{-60, 20}, {-40, 40}})));
      Modelica.Thermal.HeatTransfer.Components.HeatCapacitor wall(C = CWall, T(start = TWall_start, fixed = true)) annotation(
        Placement(transformation(extent = {{-30, 40}, {-10, 60}})));
      Modelica.Thermal.HeatTransfer.Components.ThermalResistor RIn(R = 0.5/UA) annotation(
        Placement(transformation(extent = {{0, 20}, {20, 40}})));
    equation
      connect(supply, air.ports[1]) annotation(
        Line(points = {{-100, 0}, {-20, 0}, {-20, -20}, {50, -20}}, color = {0, 127, 255}));
      connect(returnAir, air.ports[2]) annotation(
        Line(points = {{100, 0}, {80, 0}, {80, -20}, {50, -20}}, color = {0, 127, 255}));
      connect(pressureReference.ports[1], air.ports[3]) annotation(
        Line(points = {{50, -70}, {60, -70}, {60, -20}, {50, -20}}, color = {0, 127, 255}));
      connect(heatPort, air.heatPort) annotation(
        Line(points = {{0, -100}, {0, -40}, {20, -40}, {20, 0}, {30, 0}}, color = {191, 0, 0}));
      connect(TAmb, ambient.T) annotation(
        Line(points = {{0, 110}, {0, 80}, {-100, 80}, {-100, 30}, {-92, 30}}, color = {0, 0, 127}));
      connect(ambient.port, ROut.port_a) annotation(
        Line(points = {{-70, 30}, {-60, 30}}, color = {191, 0, 0}));
      connect(ROut.port_b, wall.port) annotation(
        Line(points = {{-40, 30}, {-20, 30}, {-20, 40}}, color = {191, 0, 0}));
      connect(wall.port, RIn.port_a) annotation(
        Line(points = {{-20, 40}, {-20, 30}, {0, 30}}, color = {191, 0, 0}));
      connect(RIn.port_b, air.heatPort) annotation(
        Line(points = {{20, 30}, {25, 30}, {25, 0}, {30, 0}}, color = {191, 0, 0}));
      T = air.heatPort.T;
      annotation(
        Icon(graphics = {
          Polygon(points = {{-90, -75}, {-90, 35}, {0, 85}, {90, 35}, {90, -75}, {-90, -75}}, lineColor = {25, 80, 110}, fillColor = {224, 242, 251}, fillPattern = FillPattern.Solid, lineThickness = 0.5),
          Rectangle(extent = {{-70, 15}, {-20, -75}}, lineColor = {25, 80, 110}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid),
          Ellipse(extent = {{-32, -25}, {-26, -31}}, lineColor = {25, 80, 110}, fillColor = {25, 80, 110}, fillPattern = FillPattern.Solid),
          Rectangle(extent = {{10, -40}, {70, -75}}, lineColor = {140, 95, 40}, fillColor = {215, 180, 105}, fillPattern = FillPattern.Solid),
          Line(points = {{10, -57}, {70, -57}}, color = {140, 95, 40}),
          Line(points = {{40, 40}, {40, -10}}, color = {0, 140, 210}, thickness = 1),
          Line(points = {{18, 28}, {62, 2}}, color = {0, 140, 210}, thickness = 1),
          Line(points = {{18, 2}, {62, 28}}, color = {0, 140, 210}, thickness = 1),
          Text(extent = {{-100, -80}, {100, -105}}, textString = "%name", textColor = {20, 65, 95})}),
        Documentation(info = "<html><p>One air node and one envelope node (R-C-R). The two resistances add up to the envelope UA. No solar gain, no moisture.</p></html>"));
    end ColdRoom;

    model CropLoad "Daily crop batch: arrives warm, cools down, leaves"
      parameter SI.Mass m = 500 "Crop mass per batch";
      parameter SI.SpecificHeatCapacity cp = 3500;
      parameter SI.ThermalConductance G = 100 "Crop-to-air heat transfer";
      parameter SI.Temperature TArrival = 293.15 "Temperature at loading";
      parameter Real loadingHour(min = 0, max = 23.9) = 16 "Daily loading time [h]";
      parameter Real storageHours(min = 0.5, max = 23.9) = 17 "Storage time per batch [h]";
      final parameter SI.HeatCapacity C = m*cp;
      SI.Temperature T(start = TArrival, fixed = true) "Crop temperature";
      SI.HeatFlowRate Q_flow "Heat from crop to room";
      Modelica.Blocks.Sources.BooleanPulse inRoom(width = 100*storageHours/24, period = 86400, startTime = loadingHour*3600) "True while a batch is in the room" annotation(
        Placement(transformation(extent = {{-60, -10}, {-40, 10}})));
      Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_b port annotation(
        Placement(transformation(extent = {{-10, 90}, {10, 110}})));
    equation
      Q_flow = if inRoom.y then G*(T - port.T) else 0;
      C*der(T) = -Q_flow;
      port.Q_flow = -Q_flow;
      when inRoom.y then
        reinit(T, TArrival);
      end when;
      annotation(
        Icon(graphics = {Rectangle(extent = {{-80, 20}, {80, -70}}, lineColor = {135, 80, 30}, fillColor = {225, 190, 120}, fillPattern = FillPattern.Solid), Line(points = {{-80, -25}, {80, -25}}, color = {135, 80, 30}), Ellipse(extent = {{-70, 70}, {-25, 25}}, lineColor = {70, 130, 30}, fillColor = {125, 185, 60}, fillPattern = FillPattern.Solid), Ellipse(extent = {{-22, 75}, {23, 30}}, lineColor = {185, 55, 25}, fillColor = {230, 85, 50}, fillPattern = FillPattern.Solid), Ellipse(extent = {{25, 70}, {70, 25}}, lineColor = {205, 145, 30}, fillColor = {250, 200, 50}, fillPattern = FillPattern.Solid), Text(extent = {{-100, -78}, {100, -105}}, textString = "%name", textColor = {20, 65, 95})}),
        Documentation(info = "<html><p>Each day at <i>loadingHour</i> a new batch at <i>TArrival</i> enters the room. It stays for <i>storageHours</i>.</p><p>C dT/dt = -G (T - T<sub>room</sub>)</p></html>"));
    end CropLoad;

    model PV "PV array: P = n A fAct eta G"
      parameter Integer nPV = 10 "Number of modules";
      parameter SI.Area A = 1.63 "Area of one module";
      parameter Real fAct = 0.89 "Active area fraction";
      parameter Real eta = 0.14 "Module efficiency";
      parameter Real solarFactor(min = 0, max = 1) = 1 "Irradiance factor on normal days";
      parameter Real solarFactorCloudy(min = 0, max = 1) = 1 "Irradiance factor during the cloudy period";
      parameter SI.Time tCloudyStart = 86400 "Start of cloudy period";
      parameter SI.Time tCloudyEnd = 172800 "End of cloudy period";
      Buildings.BoundaryConditions.WeatherData.Bus weaBus annotation(
        Placement(transformation(extent = {{-110, -10}, {-90, 10}})));
      Modelica.Blocks.Interfaces.RealOutput P(unit = "W") "PV power" annotation(
        Placement(transformation(extent = {{100, -10}, {120, 10}})));
      SI.Irradiance G "Irradiance on the array";
    equation
      G = (if time >= tCloudyStart and time < tCloudyEnd then solarFactorCloudy else solarFactor)*max(0, weaBus.HGloHor);
      P = nPV*A*fAct*eta*G;
      annotation(
        Icon(graphics = {Polygon(points = {{-80, 50}, {50, 50}, {80, -40}, {-50, -40}, {-80, 50}}, lineColor = {30, 70, 130}, fillColor = {50, 110, 180}, fillPattern = FillPattern.Solid), Line(points = {{-65, 5}, {65, 5}}, color = {220, 240, 255}), Line(points = {{-35, 50}, {-5, -40}}, color = {220, 240, 255}), Line(points = {{15, 50}, {45, -40}}, color = {220, 240, 255}), Ellipse(extent = {{55, 95}, {85, 65}}, lineColor = {235, 160, 20}, fillColor = {250, 200, 50}, fillPattern = FillPattern.Solid), Text(extent = {{-100, -50}, {100, -80}}, textString = "%name", textColor = {20, 65, 95})}),
        Documentation(info = "<html><p>Horizontal array using global horizontal irradiance. Between <i>tCloudyStart</i> and <i>tCloudyEnd</i> the measured irradiance is multiplied by <i>solarFactorCloudy</i> to mimic a cloudy day.</p></html>"));
    end PV;

    block ChillerControl "Chiller follows PV power"
      parameter SI.Power PChi_nominal = 2000 "Compressor power at y = 1";
      parameter SI.Power PStop = 375 "Off below this PV power";
      parameter SI.Power PStart = 475 "On above this PV power";
      parameter SI.Time tau = 120 "Soft-start time constant";
      parameter SI.Temperature TMin = 268.15 "Lowest brine outlet temperature";
      parameter SI.TemperatureDifference dTLim = 2 "Throttling band above TMin";
      Modelica.Blocks.Interfaces.RealInput PPV(unit = "W") "PV power" annotation(
        Placement(transformation(extent = {{-140, 20}, {-100, 60}})));
      Modelica.Blocks.Interfaces.RealInput TChiOut(unit = "K") "Brine leaving chiller" annotation(
        Placement(transformation(extent = {{-140, -60}, {-100, -20}})));
      Modelica.Blocks.Interfaces.RealOutput y "Compressor command 0..1" annotation(
        Placement(transformation(extent = {{100, -10}, {120, 10}})));
      Modelica.Blocks.Logical.Hysteresis pvOn(uLow = PStop, uHigh = PStart, pre_y_start = false) annotation(
        Placement(transformation(extent = {{-60, 30}, {-40, 50}})));
      Modelica.Blocks.Continuous.FirstOrder ramp(T = tau, initType = Modelica.Blocks.Types.Init.InitialOutput, y_start = 0) annotation(
        Placement(transformation(extent = {{-10, 30}, {10, 50}})));
      Real yLim "Cold limit factor 0..1";
    equation
      pvOn.u = PPV;
      ramp.u = if pvOn.y then min(1, max(0, PPV)/PChi_nominal) else 0;
      yLim = min(1, max(0, (TChiOut - TMin)/dTLim));
      y = max(0, min(1, min(ramp.y, max(0, PPV)/PChi_nominal)*yLim));
      annotation(
        Icon(graphics = {Rectangle(extent = {{-100, 100}, {100, -100}}, lineColor = {70, 60, 130}, fillColor = {245, 240, 255}, fillPattern = FillPattern.Solid, radius = 10), Ellipse(extent = {{-75, 75}, {-35, 35}}, lineColor = {235, 160, 20}, fillColor = {250, 200, 50}, fillPattern = FillPattern.Solid), Line(points = {{-20, 55}, {20, 55}}, color = {70, 60, 130}, thickness = 1, arrow = {Arrow.None, Arrow.Filled}), Text(extent = {{30, 75}, {90, 35}}, textString = "y", textColor = {70, 60, 130}), Text(extent = {{-90, 0}, {90, -60}}, textString = "Chiller\ncontrol", textColor = {70, 60, 130})}),
        Documentation(info = "<html><ul><li>On above <i>PStart</i>, off below <i>PStop</i> (PV power).</li><li>y = P<sub>PV</sub>/P<sub>nom</sub>, soft start, never above PV power.</li><li>Throttled as brine outlet approaches <i>TMin</i>.</li></ul></html>"));
    end ChillerControl;
  end Components;

  model ColdRoomSystem "Base model: PV chiller, ice tank, fan coil and cold room"
    extends Modelica.Icons.Example;
    parameter Design design annotation(
      Placement(transformation(extent = {{-280, 105}, {-220, 165}})));
    parameter String weatherFile = Modelica.Utilities.Files.loadResource("modelica://AgriCoolSimple/Resources/weather/BoaVista_Rabil_TMYx_2011_2025.mos") annotation(
      Dialog(group = "Weather", loadSelector(filter = "Weather files (*.mos)", caption = "Select weather file")));
    final parameter SI.MassFlowRate mCon = design.PChi_nominal*(1 + design.COP_nominal)/(1005*10) "Condenser air flow";

    // ---- PV and control
    Buildings.BoundaryConditions.WeatherData.ReaderTMY3 weather(filNam = weatherFile, computeWetBulbTemperature = false) annotation(
      Placement(transformation(extent = {{-190, 120}, {-150, 160}})));
    Components.PV pv(nPV = design.nPV, A = design.APV, eta = design.etaPV, fAct = design.fActPV, solarFactor = design.solarFactor, solarFactorCloudy = design.solarFactorCloudy, tCloudyStart = design.tCloudyStart, tCloudyEnd = design.tCloudyEnd) annotation(
      Placement(transformation(extent = {{-120, 120}, {-80, 160}})));
    Components.ChillerControl chiCon(PChi_nominal = design.PChi_nominal, PStart = design.PStart, PStop = design.PStop, TMin = design.TChiMin) annotation(
      Placement(transformation(extent = {{-40, 120}, {0, 160}})));
    Modelica.Blocks.Sources.Constant TSetRoom(k = design.TSet) "Room setpoint" annotation(
      Placement(transformation(extent = {{110, 125}, {130, 145}})));
    Buildings.Controls.Continuous.LimPID fanCon(controllerType = Modelica.Blocks.Types.SimpleController.PI, k = 1, Ti = 600, yMax = 1, yMin = design.yFanMin, reverseActing = false) "Room PI: more air when room is too warm" annotation(
      Placement(transformation(extent = {{160, 120}, {190, 150}})));
    Modelica.Blocks.Math.Gain fanFlow(k = design.mAir) "Fan speed to air mass flow" annotation(
      Placement(transformation(extent = {{215, 125}, {235, 145}})));

    // ---- Hydronic circuit
    Buildings.Fluid.Sources.MassFlowSource_T condenserAir(redeclare package Medium = Media.Air, nPorts = 1, use_T_in = true, m_flow = mCon) "Outdoor air to condenser" annotation(
      Placement(transformation(extent = {{-280, 20}, {-250, 50}})));
    Buildings.Fluid.Sources.Boundary_pT exhaust(redeclare package Medium = Media.Air, nPorts = 1, p = 101325, T = 303.15) annotation(
      Placement(transformation(extent = {{-100, 20}, {-130, 50}})));
    Buildings.Fluid.Chillers.Carnot_y chiller(redeclare package Medium1 = Media.Air, redeclare package Medium2 = Media.Brine, P_nominal = design.PChi_nominal, use_eta_Carnot_nominal = false, COP_nominal = design.COP_nominal, TEva_nominal = 268.15, TCon_nominal = 313.15, TAppEva_nominal = 2, TAppCon_nominal = 5, m1_flow_nominal = mCon, m2_flow_nominal = design.mBrine, dp1_nominal = 0, dp2_nominal = 10000, allowFlowReversal1 = false, allowFlowReversal2 = false, energyDynamics = Modelica.Fluid.Types.Dynamics.FixedInitial, tau1 = 30, tau2 = 30, T1_start = 303.15, T2_start = 274.15) annotation(
      Placement(transformation(extent = {{-220, -10}, {-160, 50}})));
    Buildings.Fluid.Sensors.TemperatureTwoPort senTChi(redeclare package Medium = Media.Brine, m_flow_nominal = design.mBrine, tau = 0, allowFlowReversal = false) "Brine leaving the chiller" annotation(
      Placement(transformation(extent = {{-255, -55}, {-235, -35}})));
    Buildings.Fluid.Storage.Ice.Tank iceTank(redeclare package Medium = Media.Brine, per = Buildings.Fluid.Storage.Ice.Data.Tank.Experiment(mIce_max = design.mIce), m_flow_nominal = design.mBrine, dp_nominal = 10000, SOC_start = design.SOC_start, energyDynamicsHex = Modelica.Fluid.Types.Dynamics.FixedInitial, T_start = 274.15, tauHex = 30) annotation(
      Placement(transformation(extent = {{-220, -150}, {-160, -90}})));
    Buildings.Fluid.Movers.FlowControlled_m_flow pump(redeclare package Medium = Media.Brine, m_flow_nominal = design.mBrine, dp_nominal = 30000, dpMax = 120000, inputType = Buildings.Fluid.Types.InputType.Constant, constantMassFlowRate = design.mBrine, use_riseTime = false, nominalValuesDefineDefaultPressureCurve = true, addPowerToMedium = false, energyDynamics = Modelica.Fluid.Types.Dynamics.SteadyState, allowFlowReversal = false, T_start = 274.15) "Constant flow, always on" annotation(
      Placement(transformation(extent = {{-120, -130}, {-80, -90}})));
    Buildings.Fluid.Sources.Boundary_pT brinePressure(redeclare package Medium = Media.Brine, nPorts = 1, p = 300000, T = 274.15) "Pressure reference" annotation(
      Placement(transformation(extent = {{-150, -195}, {-130, -175}})));

    // ---- Cold room, loads and air loop
    Buildings.Fluid.HeatExchangers.ConstantEffectiveness coil(redeclare package Medium1 = Media.Brine, redeclare package Medium2 = Media.Air, m1_flow_nominal = design.mBrine, m2_flow_nominal = design.mAir, eps = design.epsCoil, dp1_nominal = 10000, dp2_nominal = 100, allowFlowReversal1 = false, allowFlowReversal2 = false) "Fan coil (sensible)" annotation(
      Placement(transformation(extent = {{30, -60}, {90, 0}})));
    Buildings.Fluid.Movers.FlowControlled_m_flow fan(redeclare package Medium = Media.Air, m_flow_nominal = design.mAir, dp_nominal = 100, dpMax = 400, inputType = Buildings.Fluid.Types.InputType.Continuous, use_riseTime = false, m_flow_start = 0, nominalValuesDefineDefaultPressureCurve = true, addPowerToMedium = false, energyDynamics = Modelica.Fluid.Types.Dynamics.SteadyState, allowFlowReversal = false, T_start = 279.15) annotation(
      Placement(transformation(extent = {{140, -90}, {110, -60}})));
    Components.ColdRoom room(V = design.VRoom, UA = design.UARoom, CWall = design.CRoom, mAir_nominal = design.mAir, T_start = design.TRoom_start, TWall_start = (303.15 + design.TSet)/2) annotation(
      Placement(transformation(extent = {{160, -30}, {230, 30}})));
    Components.CropLoad crops(m = design.mCrop, cp = design.cpCrop, G = design.GCrop, TArrival = design.TCropArrival, loadingHour = design.loadingHour, storageHours = design.storageHours) annotation(
      Placement(transformation(extent = {{175, -175}, {215, -135}})));

    // ---- Results to plot
    SI.Irradiance G = pv.G "Irradiance on the PV array (cloud factor included)";
    Real room_degC = room.T - 273.15 "Room temperature [degC]";
    Real crop_degC = crops.T - 273.15 "Crop temperature [degC]";
    Real SOC = iceTank.SOC "Ice state of charge";
    SI.Power PPV = pv.P "PV power";
    SI.Power PChiller = chiller.P "Compressor power";
    SI.Power QCoil = -coil.Q2_flow "Cooling delivered to the room";
    SI.Temperature TChiOut = senTChi.T "Brine leaving the chiller";
    SI.Energy EPV(start = 0, fixed = true) "PV energy";
    SI.Energy EChiller(start = 0, fixed = true) "Compressor energy";
  equation
    connect(iceTank.port_b, pump.port_a) annotation(
      Line(points = {{-160, -120}, {-140, -120}, {-140, -110}, {-120, -110}}, color = {35, 115, 200}, thickness = 0.5));
    connect(brinePressure.ports[1], pump.port_a) annotation(
      Line(points = {{-130, -185}, {-125, -185}, {-125, -110}, {-120, -110}}, color = {35, 115, 200}, thickness = 0.5));
    connect(pump.port_b, coil.port_a1) annotation(
      Line(points = {{-80, -110}, {10, -110}, {10, -12}, {30, -12}}, color = {35, 115, 200}, thickness = 0.5));
    connect(coil.port_b1, chiller.port_a2) annotation(
      Line(points = {{90, -12}, {100, -12}, {100, 65}, {-140, 65}, {-140, 2}, {-160, 2}}, color = {35, 115, 200}, thickness = 0.5));
    connect(chiller.port_b2, senTChi.port_a) annotation(
      Line(points = {{-220, 2}, {-265, 2}, {-265, -45}, {-255, -45}}, color = {35, 115, 200}, thickness = 0.5));
    connect(senTChi.port_b, iceTank.port_a) annotation(
      Line(points = {{-235, -45}, {-230, -45}, {-230, -120}, {-220, -120}}, color = {35, 115, 200}, thickness = 0.5));
    connect(condenserAir.ports[1], chiller.port_a1) annotation(
      Line(points = {{-250, 35}, {-235, 35}, {-235, 38}, {-220, 38}}, color = {40, 150, 85}, thickness = 0.5));
    connect(chiller.port_b1, exhaust.ports[1]) annotation(
      Line(points = {{-160, 38}, {-150, 38}, {-150, 35}, {-130, 35}}, color = {40, 150, 85}, thickness = 0.5));
    connect(room.returnAir, fan.port_a) annotation(
      Line(points = {{230, 0}, {250, 0}, {250, -75}, {140, -75}}, color = {40, 150, 85}, thickness = 0.5));
    connect(fan.port_b, coil.port_a2) annotation(
      Line(points = {{110, -75}, {100, -75}, {100, -48}, {90, -48}}, color = {40, 150, 85}, thickness = 0.5));
    connect(coil.port_b2, room.supply) annotation(
      Line(points = {{30, -48}, {20, -48}, {20, 45}, {140, 45}, {140, 0}, {160, 0}}, color = {40, 150, 85}, thickness = 0.5));
    connect(crops.port, room.heatPort) annotation(
      Line(points = {{195, -135}, {195, -30}}, color = {190, 65, 55}, thickness = 0.5));
    connect(weather.weaBus, pv.weaBus) annotation(
      Line(points = {{-150, 140}, {-120, 140}}, color = {190, 160, 50}, thickness = 0.5));
    connect(weather.weaBus.TDryBul, room.TAmb) annotation(
      Line(points = {{-150, 140}, {-140, 140}, {-140, 180}, {195, 180}, {195, 33}}, color = {190, 160, 50}));
    connect(weather.weaBus.TDryBul, condenserAir.T_in) annotation(
      Line(points = {{-150, 140}, {-140, 140}, {-140, 90}, {-287, 90}, {-287, 41}, {-283, 41}}, color = {190, 160, 50}));
    connect(pv.P, chiCon.PPV) annotation(
      Line(points = {{-78, 140}, {-60, 140}, {-60, 148}, {-44, 148}}, color = {235, 135, 25}, thickness = 0.5));
    connect(senTChi.T, chiCon.TChiOut) annotation(
      Line(points = {{-245, -34}, {-245, -25}, {-277, -25}, {-277, 95}, {-55, 95}, {-55, 132}, {-44, 132}}, color = {105, 110, 125}));
    connect(chiCon.y, chiller.y) annotation(
      Line(points = {{2, 140}, {10, 140}, {10, 100}, {-245, 100}, {-245, 47}, {-226, 47}}, color = {105, 110, 125}));
    connect(TSetRoom.y, fanCon.u_s) annotation(
      Line(points = {{131, 135}, {157, 135}}, color = {105, 110, 125}));
    connect(room.T, fanCon.u_m) annotation(
      Line(points = {{233.5, 18}, {265, 18}, {265, 100}, {175, 100}, {175, 117}}, color = {105, 110, 125}));
    connect(fanCon.y, fanFlow.u) annotation(
      Line(points = {{191.5, 135}, {213, 135}}, color = {105, 110, 125}));
    connect(fanFlow.y, fan.m_flow_in) annotation(
      Line(points = {{236, 135}, {275, 135}, {275, -45}, {125, -45}, {125, -57}}, color = {105, 110, 125}));
    der(EPV) = pv.P;
    der(EChiller) = chiller.P;
    annotation(
      experiment(StartTime = 0, StopTime = 259200, Interval = 120, Tolerance = 1e-06),
      __OpenModelica_simulationFlags(s = "gbode", lv = "LOG_STATS"),
      Diagram(coordinateSystem(extent = {{-300, -240}, {300, 230}}), graphics = {
        Rectangle(extent = {{-295, 200}, {295, 85}}, lineColor = {205, 150, 60}, fillColor = {255, 250, 237}, fillPattern = FillPattern.Solid, lineThickness = 0.5, radius = 6),
        Rectangle(extent = {{-295, 80}, {-5, -215}}, lineColor = {65, 125, 185}, fillColor = {242, 248, 254}, fillPattern = FillPattern.Solid, lineThickness = 0.5, radius = 6),
        Rectangle(extent = {{5, 80}, {295, -215}}, lineColor = {65, 145, 105}, fillColor = {242, 250, 245}, fillPattern = FillPattern.Solid, lineThickness = 0.5, radius = 6),
        Text(extent = {{-295, 228}, {295, 208}}, textString = "AGRI-COOL | Off-grid cold room with PV chiller and ice storage", textColor = {40, 60, 80}),
        Text(extent = {{-150, 198}, {150, 188}}, textString = "DESIGN, PV AND CONTROL", textColor = {40, 60, 80}),
        Text(extent = {{-290, 78}, {-10, 68}}, textString = "HYDRONIC CIRCUIT (BRINE)", textColor = {40, 60, 80}),
        Text(extent = {{10, 78}, {290, 68}}, textString = "COLD ROOM, LOADS AND AIR LOOP", textColor = {40, 60, 80}),
        Text(extent = {{-295, -222}, {295, -236}}, textString = "Orange: PV power   |   Blue: brine   |   Green: air   |   Red: heat   |   Grey: control   |   Yellow: weather", textColor = {80, 80, 80})}),
      Documentation(info = "<html>
<h4>How to use</h4>
<ol><li>Double-click <b>design</b> and change a value.</li><li>Simulate (3 days).</li><li>Plot <b>G</b>, <b>room_degC</b> and <b>SOC</b>.</li></ol>
<h4>How it works</h4>
<ul>
<li><b>Chiller</b> runs on PV power only. Its cold brine charges the ice tank.</li>
<li><b>Ice tank</b> feeds the fan coil. At night the room is cooled by melting ice.</li>
<li><b>Fan</b> speed is set by a PI controller on room temperature.</li>
<li><b>Pump</b> runs at constant flow.</li>
<li><b>Crops</b> arrive warm every day at the loading time.</li>
</ul>
<h4>Simplifications</h4>
<p>No battery, sensible cooling only, horizontal PV, no solar gain on the room.</p>
</html>"));
  end ColdRoomSystem;

  package Scenarios "Ready-to-run course scenarios"
    extends Modelica.Icons.ExamplesPackage;

    model MorningLoading "Crops loaded at 07:00"
      extends AgriCoolSimple.ColdRoomSystem(design(loadingHour = 7));
      annotation(
        experiment(StartTime = 0, StopTime = 259200, Interval = 120, Tolerance = 1e-06),
        __OpenModelica_simulationFlags(s = "gbode", lv = "LOG_STATS"),
        Documentation(info = "<html><p>Crops arrive while the sun is up. The chiller handles most of the load.</p></html>"));
    end MorningLoading;

    model AfternoonLoading "Crops loaded at 16:00"
      extends AgriCoolSimple.ColdRoomSystem(design(loadingHour = 16));
      annotation(
        experiment(StartTime = 0, StopTime = 259200, Interval = 120, Tolerance = 1e-06),
        __OpenModelica_simulationFlags(s = "gbode", lv = "LOG_STATS"),
        Documentation(info = "<html><p>Crops arrive near sunset. The ice tank handles most of the load.</p></html>"));
    end AfternoonLoading;

    model CloudyDay2 "Morning loading, 25 % PV on day 2"
      extends AgriCoolSimple.ColdRoomSystem(design(loadingHour = 7, solarFactorCloudy = 0.25));
      annotation(
        experiment(StartTime = 0, StopTime = 259200, Interval = 120, Tolerance = 1e-06),
        __OpenModelica_simulationFlags(s = "gbode", lv = "LOG_STATS"),
        Documentation(info = "<html><p>Day 2 has 25 % of the normal irradiance; days 1 and 3 are normal. Can the ice bridge the gap?</p></html>"));
    end CloudyDay2;
  end Scenarios;
  annotation(
    uses(Modelica(version = "4.1.0"), Buildings(version = "13.0.0")),
    version = "1.1.0",
    Documentation(info = "<html>
<p>Teaching model of an off-grid cold room: PV-driven chiller, ice storage, fan coil and daily crop loading.</p>
<p><b>Start:</b> open <i>Scenarios</i>, simulate a model, double-click <i>design</i> to change it.</p>
<p><b>Setup:</b> Modelica 4.1.0, Buildings 13.0.0. Keep this file next to <i>Resources/weather/</i>.</p>
</html>"));
end AgriCoolSimple;
