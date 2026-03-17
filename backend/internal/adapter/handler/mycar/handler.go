package mycar

import (
	"net/http"

	mycarUsecase "backend/internal/usecase/mycar"

	"github.com/gin-gonic/gin"
)

type Handler struct {
	usecase mycarUsecase.Usecase
}

func NewHandler(usecase mycarUsecase.Usecase) *Handler {
	return &Handler{usecase: usecase}
}

type RegisterMyCarRequest struct {
	UserID       string `json:"user_id" binding:"required"`
	LicensePlate string `json:"license_plate" binding:"required"`
}

func (h *Handler) RegisterMyCar(c *gin.Context) {
	var req RegisterMyCarRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  400,
			"message": "invalid request",
		})
		return
	}

	myCarID, err := h.usecase.RegisterMyCar(c.Request.Context(), req.UserID, req.LicensePlate)
	if err != nil {
		if err.Error() == "car already registered" {
			c.JSON(http.StatusConflict, gin.H{
				"status":  409,
				"message": err.Error(),
			})
			return
		}

		if err.Error() == "car info not found" {
			c.JSON(http.StatusNotFound, gin.H{
				"status":  404,
				"message": err.Error(),
			})
			return
		}

		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  500,
			"message": "failed to register my car",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":   200,
		"message":  "success",
		"mycar_id": myCarID,
	})
}

func (h *Handler) GetMyCars(c *gin.Context) {
	userID := c.Param("user_id")

	cars, err := h.usecase.GetMyCarsByUserID(c.Request.Context(), userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  500,
			"message": "failed to get my cars",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  200,
		"message": "success",
		"data":    cars,
	})
}
