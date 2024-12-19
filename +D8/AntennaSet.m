classdef AntennaSet < handle
    properties (SetAccess = protected)
        frequency string {mustBeScalarOrEmpty}
        positions
        nPositions
        antinodeLocations logical
        mapSize
    end
    
    methods
        function obj = AntennaSet(frequency,antennaMap)
            arguments
                frequency = string.empty
                antennaMap string = string.empty;
            end
            obj.frequency = frequency;
            if ~isempty(antennaMap)
                obj.mapSize = size(antennaMap);
                obj.findAntennaPositions(antennaMap);
            end
        end
        
        function findAntennaPositions(self,antennaMap)
            linearIndx = find(antennaMap == self.frequency);
            [row,col] = ind2sub(self.mapSize,linearIndx);
            positions = [row, col]; %#ok<*PROPLC>
            nPositions = height(positions);
            positionsCell = mat2cell(positions,ones(nPositions,1),2);

            self.nPositions = nPositions;
            self.positions = containers.Map(1:nPositions,positionsCell);
        end

        function locateAntinodes(self)
            self.antinodeLocations = false(self.mapSize);
            if self.nPositions == 1
                return
            end

            % loop through all pairs of 2 antennas and find antinodes
            antennaCombinations = nchoosek(1:self.nPositions,2);
            nAntennaCombinations = height(antennaCombinations);
            for i = 1:nAntennaCombinations
                thisCombination = antennaCombinations(i,:);
                antennaPosition1 = self.positions(thisCombination(1));
                antennaPosition2 = self.positions(thisCombination(2));
                displacement1to2 = antennaPosition2 - antennaPosition1;
                
                antinodePosition1 = antennaPosition1 - displacement1to2;
                antinodePosition2 = antennaPosition2 + displacement1to2;
                
                if self.checkLocationIsInMap(antinodePosition1)
                    antinodePosition1 = num2cell(antinodePosition1);
                    self.antinodeLocations(antinodePosition1{:}) = true;
                end
                
                if self.checkLocationIsInMap(antinodePosition2)
                    antinodePosition2 = num2cell(antinodePosition2);
                    self.antinodeLocations(antinodePosition2{:}) = true;
                end
            end
        end

        function isInMap = checkLocationIsInMap(self,location)
            assert(all(size(location) == [1,2]))
            row = location(1); col = location(2);
            if row < 1 || col < 1 || row > self.mapSize(1) || col > self.mapSize(2)
                isInMap = false;
            else
                isInMap = true;
            end
        end
    end
end

