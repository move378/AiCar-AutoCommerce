package entity

type VehicleBrand struct {
	ID      string  `gorm:"column:id;type:uuid;primaryKey"`
	Name    string  `gorm:"column:name"`
	Country *string `gorm:"column:country"`
	LogoURL *string `gorm:"column:logo_url"`
}

func (VehicleBrand) TableName() string { return "vehicles_brands" }

type VehicleModel struct {
	ID             string  `gorm:"column:id;type:uuid;primaryKey"`
	BrandID        string  `gorm:"column:brand_id;type:uuid"`
	ModelName      string  `gorm:"column:model_name"`
	Classification *string `gorm:"column:classification"`
	Segment        *string `gorm:"column:segment"`

	Brand VehicleBrand `gorm:"foreignKey:BrandID"`
}

func (VehicleModel) TableName() string { return "vehicles_models" }

type VehicleTrim struct {
	ID               string   `gorm:"column:id;type:uuid;primaryKey"`
	ModelID          string   `gorm:"column:model_id;type:uuid"`
	TrimName         string   `gorm:"column:trim_name"`
	BodyType         *string  `gorm:"column:body_type"`
	BodyTypeCode     *string  `gorm:"column:body_type_code"`
	Year             *string  `gorm:"column:year"`
	BasePrice        *int64   `gorm:"column:base_price"`
	FuelType         *string  `gorm:"column:fuel_type"`
	SeatingCapacity  *int16   `gorm:"column:seating_capacity"`
	MaxOutput        *int     `gorm:"column:max_output"`
	DriveType        *float64 `gorm:"column:drive_type"`
	Acceleration     *float64 `gorm:"column:acceleration"`
	Length           *int     `gorm:"column:length"`
	Width            *int     `gorm:"column:width"`
	Height           *int     `gorm:"column:height"`
	CurbWeight       *int     `gorm:"column:curb_weight"`
	Transmission     *string  `gorm:"column:transmission"`
	TransmissionType *string  `gorm:"column:transmission_type"`
	ImageURL         *string  `gorm:"column:image_url"`
	TopSpeed         *int     `gorm:"column:top_speed"`
	Doors            *int16   `gorm:"column:doors"`

	Model   VehicleModel       `gorm:"foreignKey:ModelID"`
	IceSpec *VehicleIceSpec    `gorm:"foreignKey:TrimID"`
	EvSpec  *VehicleEvSpec     `gorm:"foreignKey:TrimID"`
	Images  []VehicleTrimImage `gorm:"foreignKey:TrimID"`
}

func (VehicleTrim) TableName() string { return "vehicles_trims" }

type VehicleIceSpec struct {
	TrimID           string   `gorm:"column:trim_id;type:uuid;primaryKey"`
	Displacement     *int     `gorm:"column:displacement"`
	FuelTankCapacity *int     `gorm:"column:fuel_tank_capacity"`
	FuelEffCombined  *float64 `gorm:"column:fuel_eff_combined"`
	FuelEffCity      *float64 `gorm:"column:fuel_eff_city"`
	FuelEffHighway   *float64 `gorm:"column:fuel_eff_highway"`
	EnergyGrade      *int     `gorm:"column:energy_grade"`
	Cylinder         *int16   `gorm:"column:cylinder"`
}

func (VehicleIceSpec) TableName() string { return "vehicles_ice_specs" }

type VehicleEvSpec struct {
	TrimID          string   `gorm:"column:trim_id;type:uuid;primaryKey"`
	BatteryCapacity *float64 `gorm:"column:battery_capacity"`
	MaxRange        *int     `gorm:"column:max_range"`
	EffCombined     *float64 `gorm:"column:eff_combined"`
	EffCity         *float64 `gorm:"column:eff_city"`
	EffHighway      *float64 `gorm:"column:eff_highway"`
	EnergyGrade     *int     `gorm:"column:energy_grade"`
}

func (VehicleEvSpec) TableName() string { return "vehicles_ev_specs" }

type VehicleTrimImage struct {
	ID        string  `gorm:"column:id;type:uuid;primaryKey"`
	TrimID    string  `gorm:"column:trim_id;type:uuid"`
	ImageURL  string  `gorm:"column:image_url"`
	ImageType *string `gorm:"column:image_type"`
}

func (VehicleTrimImage) TableName() string { return "vehicles_trim_images" }
