/// 상담 단계
enum ConsultationStep {
  /// 1단계: 선호도 & 구매의사
  brand,
  vehicleType,
  budget,

  /// 2단계: 용도 & 라이프스타일
  driver,
  purpose,

  /// 3단계: 주관식
  freeText,

  /// 결과 표시
  result,

  /// 자유 채팅 (결과 이후)
  freeChat,
}

/// 누적된 사용자 답변
class ConsultationAnswers {
  String? brand;
  String? vehicleType;
  String? budgetRange;
  String? driver;
  String? purpose;
  String? freeText;

  /// 필터 조건으로 변환
  bool matchesVehicle({
    required String vehicleBrand,
    required int vehiclePrice,
    required String vehicleModel,
    required String vehicleFuelType,
  }) {
    if (brand != null && brand != '상관없음') {
      if (!vehicleBrand.toLowerCase().contains(brand!.toLowerCase())) {
        return false;
      }
    }
    if (vehicleType != null && vehicleType != '상관없음') {
      final type = vehicleType!.toLowerCase();
      final model = vehicleModel.toLowerCase();
      if (type == 'suv' && !_isSuv(model)) return false;
      if (type == '세단' && !_isSedan(model)) return false;
      if (type == '쿠페' && !_isCoupe(model)) return false;
    }
    if (budgetRange != null && budgetRange != '상관없음') {
      final range = _parseBudgetRange(budgetRange!);
      if (range != null) {
        if (vehiclePrice < range.$1 || vehiclePrice > range.$2) return false;
      }
    }
    return true;
  }

  bool _isSuv(String model) {
    return model.contains('x') ||
        model.contains('gl') ||
        model.contains('q') ||
        model.contains('xc') ||
        model.contains('eq');
  }

  bool _isSedan(String model) {
    return model.contains('시리즈') ||
        model.contains('클래스') ||
        model.contains('a4') ||
        model.contains('a6') ||
        model.contains('es') ||
        model.contains('s60') ||
        model.contains('e ') ||
        model.contains('c ');
  }

  bool _isCoupe(String model) {
    return model.contains('쿠페') ||
        model.contains('coupe') ||
        model.contains('coupé') ||
        model.contains('cle') ||
        model.contains('cla');
  }

  (int, int)? _parseBudgetRange(String range) {
    if (range.contains('5천~7천')) return (50000000, 70000000);
    if (range.contains('7천~9천')) return (70000000, 90000000);
    if (range.contains('9천~1억')) return (90000000, 100000000);
    return null;
  }
}

/// 질문 정의
class ConsultationQuestion {
  const ConsultationQuestion({
    required this.step,
    required this.question,
    this.choices,
  });

  final ConsultationStep step;
  final String question;
  final List<String>? choices;
}

/// 전체 질문 목록
const consultationQuestions = [
  ConsultationQuestion(
    step: ConsultationStep.brand,
    question: '어떤 브랜드에 관심이 있으세요?',
    choices: ['벤츠', 'BMW', '아우디', '볼보', '테슬라', '렉서스', '상관없음'],
  ),
  ConsultationQuestion(
    step: ConsultationStep.vehicleType,
    question: '어떤 차종을 선호하세요?',
    choices: ['SUV', '세단', '쿠페', '상관없음'],
  ),
  ConsultationQuestion(
    step: ConsultationStep.budget,
    question: '예산은 어느 정도로 생각하세요?',
    choices: ['5천~7천', '7천~9천', '9천~1억', '상관없음'],
  ),
  ConsultationQuestion(
    step: ConsultationStep.driver,
    question: '주로 누가 운전하시나요?',
    choices: ['본인', '배우자', '가족 공용'],
  ),
  ConsultationQuestion(
    step: ConsultationStep.purpose,
    question: '차량의 주 용도는 무엇인가요?',
    choices: ['출퇴근', '주말 나들이', '장거리 여행', '업무용', '복합'],
  ),
  ConsultationQuestion(
    step: ConsultationStep.freeText,
    question: '차량 구매 시 가장 중요하게 생각하는 점을 자유롭게 알려주세요!',
    choices: null,
  ),
];
