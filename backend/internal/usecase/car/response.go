package car

type CarImageResponse struct {
	ID          string `json:"id"`
	CarID       string `json:"car_id"`
	ImageURL    string `json:"image_url"`
	IsThumbnail bool   `json:"is_thumbnail"`
	SortOrder   int    `json:"sort_order"`
}

type CarDetailResponse struct {
	ID                 string             `json:"id"`
	ModelID            string             `json:"model_id"`
	TrimName           *string            `json:"trim_name"`
	Year               int                `json:"year"`
	Price              int                `json:"price"`
	FuelType           *string            `json:"fuel_type"`
	FuelEfficiency     *float64           `json:"fuel_efficiency"`
	Transmission       *string            `json:"transmission"`
	EngineDisplacement *int               `json:"engine_displacement"`
	Status             string             `json:"status"`
	ThumbnailURL       *string            `json:"thumbnail_url"`
	Images             []CarImageResponse `json:"images"`
}

type CarListItemResponse struct {
	ID                 string   `json:"id"`
	ModelID            string   `json:"model_id"`
	BrandName          string   `json:"brand_name"`
	ModelName          string   `json:"model_name"`
	TrimName           *string  `json:"trim_name"`
	Year               int      `json:"year"`
	Price              int      `json:"price"`
	FuelType           *string  `json:"fuel_type"`
	FuelEfficiency     *float64 `json:"fuel_efficiency"`
	Transmission       *string  `json:"transmission"`
	EngineDisplacement *int     `json:"engine_displacement"`
	Status             string   `json:"status"`
	ThumbnailURL       *string  `json:"thumbnail_url"`
}
