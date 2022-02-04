{
  Description: Genetic Algorithm optimizer.

  Copyright (C) 2022 Melchiorre Caruso <melchiorrecaruso@gmail.com>

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
}

unit GeneticAlgorithm;

{$mode objfpc}

interface

uses
  Classes, Math, SysUtils;

type
  // TPerson class

  TGenome = array[0..19] of byte;

  TPerson = class(TObject)
  public
    Cost: double;
    Genome: TGenome;
    Population: longint;
  public
    constructor Create; overload;
    constructor Create(Parent0, Parent1: TPerson); overload;
    destructor Destroy; override;
    procedure MarkToRecalculate;
    function IsEqual(Person: tperson): boolean;
    procedure CalculateCost;
  end;

  // TPopulation class

  TPopulation = class(TList)
  public
    constructor Create; overload;
    destructor Destroy; override;
    procedure Add(P: TPerson);
    procedure MarkToRecalculate;
    function HasPerson(Person: TPerson): boolean;
  end;

  // TPopulations class

  TPopulations = class(TList)
  public
    CurrentAge: longint;
    CurrentPopulation: longint;
    Improvements: longint;
  public
    constructor Create; overload;
    destructor Destroy; override;
    procedure Live;
    procedure MarkToRecalculate;
  end;

  // TGeneticAlgorithm class

  TGeneticAlgorithm = class
  private
    fWorld: TPopulations;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Execute;
  end;

var
  BestCost: double = 999999999;
  BestGenome: TGenome;

implementation

const
  CrossoverProbability = 0.15;
  MutationProbability  = 0.80;

// Math routines

function EggHolder(const X, Y: double): double;
begin
  Result := -(y + 47)*sin(sqrt(abs(y + x/2 + 47))) -x*sin(sqrt(abs(x - (y + 47))));
end;

procedure GetXY(const Genome: TGenome; var X, Y: double);
begin
  X := Genome[1]*0.1 +
       Genome[2]*0.01 +
       Genome[3]*0.001 +
       Genome[4]*0.0001 +
       Genome[5]*0.00001 +
       Genome[6]*0.000001 +
       Genome[7]*0.0000001 +
       Genome[8]*0.00000001 +
       Genome[9]*0.000000001;

  X := 512 * X;
  if Genome[0] in [0, 1, 2 , 3, 4] then X := -X;

  Y := Genome[11]*0.1 +
       Genome[12]*0.01 +
       Genome[13]*0.001 +
       Genome[14]*0.0001 +
       Genome[15]*0.00001 +
       Genome[16]*0.000001 +
       Genome[17]*0.0000001 +
       Genome[18]*0.00000001 +
       Genome[19]*0.000000001;

  Y := 512 * Y;
  if Genome[10] in [0, 1, 2 , 3, 4] then Y := -Y;
end;

/// TPerson

constructor TPerson.Create;
var
  i: longint;
begin
  for i := Low(Genome) to High(Genome) do
  begin
    Genome[i] := Random(10);
  end;
  Cost := 0;
end;

constructor TPerson.Create(Parent0, Parent1: TPerson);
var
  i: longint;
  Parents: array[0..1] of TPerson;
  ParentIndex: longint;
begin
  Parents[0]  := Parent0;
  Parents[1]  := Parent1;
  ParentIndex := Random(2);
  for i := Low(Genome) to High(Genome) do
  begin
    // Crossover
    if Random < CrossoverProbability then
    begin
      ParentIndex := ParentIndex xor 1;
    end;
    Genome[i] := Parents[ParentIndex].Genome[i];

    // Mutation
    if Random < MutationProbability then
    begin
      Genome[i] := Random(10);
    end;
  end;
  Cost := 0;
end;

destructor TPerson.Destroy;
begin
  inherited Destroy;
end;

procedure TPerson.MarkToRecalculate;
begin
  Cost := 0;
end;

function TPerson.IsEqual(Person: TPerson): boolean;
var
  i: longint;
begin
  Result := False;
  for i := Low(Genome) to High(Genome) do
  begin
    if Genome[i] <> Person.Genome[i] then Exit;
  end;
  Result := True;
end;

procedure TPerson.CalculateCost;
var
  X: double;
  Y: double;
begin
  GetXY(Genome, X, Y);
  Cost := EggHolder(X, Y);
end;

/// TPopulation

constructor TPopulation.Create;
begin
  inherited Create;
end;

procedure TPopulation.Add(P: TPerson);
var
  i: longint;
begin
  i := 0;
  while (i < Count) and (TPerson(Items[i]).Cost < P.Cost) do
  begin
    Inc(i);
  end;
  Insert(i, P);
end;

procedure TPopulation.MarkToRecalculate;
begin
  while Count > 1 do
  begin
    TPerson(Extract(Last)).Destroy;
  end;
  if Count > 0 then TPerson(First).MarkToRecalculate;
end;

destructor TPopulation.Destroy;
begin
  while Count > 0 do
  begin
    TPerson(Extract(First)).Destroy;
  end;
  inherited Destroy;
end;

function TPopulation.HasPerson(Person: TPerson): boolean;
var
  i: longint;
begin
  Result := True;
  for i := 0 to Count - 1 do
  begin
    if Person.IsEqual(TPerson(Items[i])) then Exit;
  end;
  Result := False;
end;

/// TPopulations

constructor TPopulations.Create;
begin
  inherited Create;
  CurrentPopulation := 0;
  CurrentAge := 0;
  Improvements := 0;
  while Count < 15 do
  begin
    Add(TPopulation.Create);
  end;
end;

procedure TPopulations.Live;
var
  i: longint;
  FullSize: longint;
  HalfSize: longint;
  Population1: TPopulation;
  Population2: TPopulation;
  Parent1: TPerson;
  Parent2: TPerson;
  Person: TPerson;
  X, Y: double;
begin
  FullSize := 1;
  HalfSize := 1;

  if CurrentAge mod 2000 = 0 then
  begin
    for i := 0 to Count - 1 do
    begin
      TPopulation(Items[i]).MarkToRecalculate;
    end;
    Inc(CurrentAge);
  end;

  Population1 := TPopulation(Items[CurrentPopulation]);

  if Population1.Count = 0 then
  begin
    Person := TPerson.Create;
    // generate random creature
  end
  else if TPerson(Population1.First).Cost = 0 then
  begin
    Person := TPerson(Population1.Extract(Population1.First));
    // recalculate creature estimation
  end
  else
  begin
    repeat
      repeat
        Population2 := TPopulation(
          Items[Max(0, Min(CurrentPopulation + Random(3) - 1, Count - 1))]);
      until Population2.Count > 0;
      Parent1 := TPerson(Population1.Items[Random(Population1.Count)]);
      Parent2 := TPerson(Population2.Items[Random(Population2.Count)]);
    until Parent1 <> Parent2;

    repeat
      Person := TPerson.Create(Parent1, Parent2);
      if Population1.HasPerson(Person) then
      begin
        FreeAndNil(Person);
      end;
    until Person <> nil;
    // creatures optimization
  end;

  begin
    Person.Population := CurrentPopulation + 1;
    Person.CalculateCost;
  end;

  begin
    if Population1.Count > 0 then
    begin
      if TPerson(Population1.First).Cost > 0 then Inc(CurrentAge);
      if TPerson(Population1.First).Cost > Person.Cost then Inc(Improvements);
    end;
    Population1.Add(Person);

    if Population1.Count > 0 then
    begin
      if TPerson(Population1.First).Cost < BestCost then
      begin
        BestCost   := TPerson(Population1.First).Cost;
        BestGenome := TPerson(Population1.First).Genome;
      end;
    end;

    if (Population1.Count > FullSize) and (TPerson(Population1.First).Cost > 0) then
    begin
      while Population1.Count > HalfSize do
      begin
        TPerson(Population1.Extract(Population1.Last)).Destroy;
      end;
    end;
  end;

  if CurrentPopulation = 14 then
  begin
    GetXY(BestGenome, X, Y);
    writeln(format('%10d turn, %5d jumps (%2.1f%%), %0.4f mm (%0.4f, %0.4f)',
      [CurrentAge, Improvements, Improvements / (CurrentAge + 1) * 100, BestCost, X, Y]));
  end;
  CurrentPopulation := (CurrentPopulation + 1) mod 15;
end;

procedure TPopulations.MarkToRecalculate;
var
  i: longint;
begin
  for i := 0 to Count - 1 do
  begin
    TPopulation(Items[i]).MarkToRecalculate;
  end;
  CurrentPopulation := 0;
  CurrentAge := 0;
  Improvements := 0;
end;

destructor TPopulations.Destroy;
begin
  while Count > 0 do
  begin
    TPopulation(Extract(First)).Free;
  end;
  inherited Destroy;
end;

/// TGeneticAlgorithm

constructor TGeneticAlgorithm.Create;
begin
  inherited Create;
  fWorld := TPopulations.Create;
end;

destructor TGeneticAlgorithm.Destroy;
begin
  fWorld.Free;
  inherited Destroy;
end;

procedure TGeneticAlgorithm.Execute;
begin
  BestCost := 99999999;
  while fWorld.CurrentAge < 1000000 do
  begin
    fWorld.Live;
  end;
end;

end.
