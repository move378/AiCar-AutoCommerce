package vehicle

type BrandResponse struct {
	ID      string  `json:"id"`
	Name    string  `json:"name"`
	Country *string `json:"country,omitempty"`
	LogoURL *string `json:"logo_url,omitempty"`
}

type TrimListItemResponse struct {
	ID              string   `json:"id"`
	BrandName       string   `json:"brand_name"`
	ModelName       string   `json:"model_name"`
	TrimName        string   `json:"trim_name"`
	Year            *string  `json:"year,omitempty"`
	BasePrice       *int64   `json:"base_price,omitempty"`
	FuelType        *string  `json:"fuel_type,omitempty"`
	BodyType        *string  `json:"body_type,omitempty"`
	Segment         *string  `json:"segment,omitempty"`
	ImageURL        *string  `json:"image_url,omitempty"`
	FuelEffCombined *float64 `json:"fuel_eff_combined,omitempty"`
}

type SearchResult struct {
	Items []TrimListItemResponse
	Total int64
}

type TrimImageResponse struct {
	ID        string  `json:"id"`
	ImageURL  string  `json:"image_url"`
	ImageType *string `json:"image_type,omitempty"`
}

type IceSpecResponse struct {
	Displacement     *int     `json:"displacement,omitempty"`
	FuelTankCapacity *int     `json:"fuel_tank_capacity,omitempty"`
	FuelEffCombined  *float64 `json:"fuel_eff_combined,omitempty"`
	FuelEffCity      *float64 `json:"fuel_eff_city,omitempty"`
	FuelEffHighway   *float64 `json:"fuel_eff_highway,omitempty"`
	EnergyGrade      *int     `json:"energy_grade,omitempty"`
	Cylinder         *int16   `json:"cylinder,omitempty"`
}

type EvSpecResponse struct {
	BatteryCapacity *float64 `json:"battery_capacity,omitempty"`
	MaxRange        *int     `json:"max_range,omitempty"`
	EffCombined     *float64 `json:"eff_combined,omitempty"`
	EffCity         *float64 `json:"eff_city,omitempty"`
	EffHighway      *float64 `json:"eff_highway,omitempty"`
	EnergyGrade     *int     `json:"energy_grade,omitempty"`
}

type TrimDetailResponse struct {
	ID               string             `json:"id"`
	BrandName        string             `json:"brand_name"`
	BrandLogoURL     *string            `json:"brand_logo_url,omitempty"`
	ModelName        string             `json:"model_name"`
	Classification   *string            `json:"classification,omitempty"`
	Segment          *string            `json:"segment,omitempty"`
	TrimName         string             `json:"trim_name"`
	BodyType         *string            `json:"body_type,omitempty"`
	Year             *string            `json:"year,omitempty"`
	BasePrice        *int64             `json:"base_price,omitempty"`
	FuelType         *string            `json:"fuel_type,omitempty"`
	SeatingCapacity  *int16             `json:"seating_capacity,omitempty"`
	MaxOutput        *int               `json:"max_output,omitempty"`
	Acceleration     *float64           `json:"acceleration,omitempty"`
	Length           *int               `json:"length,omitempty"`
	Width            *int               `json:"width,omitempty"`
	Height           *int               `json:"height,omitempty"`
	CurbWeight       *int               `json:"curb_weight,omitempty"`
	Transmission     *string            `json:"transmission,omitempty"`
	TransmissionType *string            `json:"transmission_type,omitempty"`
	ImageURL         *string            `json:"image_url,omitempty"`
	TopSpeed         *int               `json:"top_speed,omitempty"`
	Doors            *int16             `json:"doors,omitempty"`
	IceSpec          *IceSpecResponse   `json:"ice_spec,omitempty"`
	EvSpec           *EvSpecResponse    `json:"ev_spec,omitempty"`
	Images           []TrimImageResponse `json:"images"`
}
