package external

import (
	"context"
	"errors"
)

type CarInfo struct {
	LicensePlate string
	Brand        string
	Model        string
	Year         int
	FuelType     string
}

type CarInfoProvider interface {
	GetCarInfoByPlate(ctx context.Context, licensePlate string) (*CarInfo, error)
}

type MockCarInfoProvider struct{}

func NewMockCarInfoProvider() *MockCarInfoProvider {
	return &MockCarInfoProvider{}
}

func (m *MockCarInfoProvider) GetCarInfoByPlate(ctx context.Context, licensePlate string) (*CarInfo, error) {
	mockCars := map[string]CarInfo{
		"12가3456": {
			LicensePlate: "12가3456",
			Brand:        "Hyundai",
			Model:        "Avante",
			Year:         2022,
			FuelType:     "Gasoline",
		},
		"34나5678": {
			LicensePlate: "34나5678",
			Brand:        "Kia",
			Model:        "K5",
			Year:         2021,
			FuelType:     "Gasoline",
		},
		"56다7890": {
			LicensePlate: "56다7890",
			Brand:        "Genesis",
			Model:        "G80",
			Year:         2023,
			FuelType:     "Diesel",
		},
		"78라1234": {
			LicensePlate: "78라1234",
			Brand:        "BMW",
			Model:        "320i",
			Year:         2020,
			FuelType:     "Gasoline",
		},
		"90마4321": {
			LicensePlate: "90마4321",
			Brand:        "Mercedes-Benz",
			Model:        "E300",
			Year:         2019,
			FuelType:     "Gasoline",
		},
		"11바1111": {
			LicensePlate: "11바1111",
			Brand:        "Tesla",
			Model:        "Model 3",
			Year:         2024,
			FuelType:     "Electric",
		},
	}

	car, ok := mockCars[licensePlate]
	if !ok {
		return nil, errors.New("car info not found")
	}

	return &car, nil
}
