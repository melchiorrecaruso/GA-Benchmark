{
  Description: Genetic Algorithm benchmark.

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

program Benchmark;

{$mode objfpc}

uses
 {$IFDEF UNIX} cThreads, {$ENDIF} Classes,
  GeneticAlgorithm, SysUtils;

type
  // TBenchmark

  TBenchmark = class
  private
    fOptimizer: TGeneticAlgorithm;
  public
    procedure Execute;
  end;

  procedure TBenchmark.Execute;
  begin
    Writeln('Simulated Annealing Benchmark');
    Writeln('Eggholder function');
    writeln;

    fOptimizer := TGeneticAlgorithm.Create;
    fOptimizer.Execute;
    fOptimizer.Destroy;
  end;

  // Main Block

var
  Bench: TBenchmark;

begin
  Randomize;

  Bench := TBenchmark.Create;
  Bench.Execute;
  Bench.Destroy;
end.
