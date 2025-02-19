<details>
<summary><strong>JVM Heap 메모리 사용률 모니터링</strong></summary>

# 📌 JVM Heap 메모리 사용률 모니터링

## 📊 PromQL 쿼리
```promql
sum(jvm_memory_used_bytes{application="$application", instance="$instance", area="heap"}) 
* 100 / 
sum(jvm_memory_max_bytes{application="$application", instance="$instance", area="heap"})
```

## 🔍 설명
- **Heap 메모리 사용량(%)**을 계산하는 공식.
- **`jvm_memory_used_bytes`** → 현재 사용 중인 Heap 메모리 크기.
- **`jvm_memory_max_bytes`** → JVM에서 설정된 Heap 메모리 최대 크기.
- 두 값을 나누어 **현재 Heap이 전체 Heap에서 차지하는 비율(%)을 구함.**

## 🔹 예제
| 메트릭 | 값 (Bytes) |
|---------|------------|
| `jvm_memory_used_bytes` | 1,500,000,000 (1.5GB) |
| `jvm_memory_max_bytes` | 4,000,000,000 (4GB) |

```math
(1,500,000,000 * 100) / 4,000,000,000 = 37.5%
```
📌 **결과: 현재 Heap 메모리 사용률은 `37.5%`**

---

## 🔥 왜 모니터링해야 할까?
✔ **Heap 사용률이 높으면?**
- JVM이 **Garbage Collection(GC)을 자주 실행** → **성능 저하** 가능성
- Heap이 계속 **90% 이상 유지** → **OutOfMemoryError(OOM) 발생 위험 증가**
- 특정 서비스에서 **Heap 사용량이 계속 증가** → **메모리 누수(Leak) 가능성**

✔ **Heap 사용률이 낮으면?**
- 메모리가 충분히 확보됨 → **JVM이 안정적으로 실행 중**
- 하지만 너무 낮으면 JVM 설정이 과도한 것일 수도 있음 → **메모리 낭비 가능성**

---

## 📌 Grafana에서 JVM Heap 모니터링 대시보드 설정
### 🖥️ 패널 설정
- **패널 유형:** Line Chart
- **X축:** 시간 (Timestamp)
- **Y축:** Heap 메모리 사용률 (%)
- **Y축 단위 변경:** Percent (`percent (0-100)`)
- **PromQL 쿼리:**
```promql
sum(jvm_memory_used_bytes{area="heap"}) * 100 / sum(jvm_memory_max_bytes{area="heap"})
```

### 🚨 임계값(Threshold) 설정
- **90% 이상** → 🔴 **위험 (OOM 발생 가능성 높음)**
- **80~90%** → 🟠 **주의 (GC 과부하 가능성)**
- **50~80%** → 🟢 **정상**
- **50% 이하** → 🔵 **메모리 여유 있음**

---

## ✅ 결론
- **JVM Heap 사용량을 %로 계산하여 실시간으로 모니터링 가능.**
- **Heap 사용률이 90% 이상 지속되면 OOM 위험 증가 → 적극적인 관리 필요!**
- **Grafana에서 Heap 메모리 사용 패턴을 분석하고 JVM 튜닝에 활용할 수 있음.**
</details>


<details>
<summary><strong>JVM Non-Heap 메모리 사용률 모니터링</strong></summary>
# 📌 JVM Non-Heap 메모리 사용률 모니터링

## 📊 PromQL 쿼리
```promql
sum(jvm_memory_used_bytes{application="$application", instance="$instance", area="nonheap"}) 
* 100 / 
sum(jvm_memory_max_bytes{application="$application", instance="$instance", area="nonheap"})
```

## 🔍 설명
- **Non-Heap 메모리 사용량(%)**을 계산하는 공식.
- **`jvm_memory_used_bytes`** → 현재 사용 중인 **Non-Heap** 메모리 크기.
- **`jvm_memory_max_bytes`** → JVM에서 설정된 **Non-Heap** 메모리 최대 크기.
- 두 값을 나누어 **현재 Non-Heap 영역이 전체 Non-Heap에서 차지하는 비율(%)을 구함.**

## 🔹 Heap vs Non-Heap 차이
| **메모리 영역** | **설명** |
|---------------|---------|
| **Heap** | 애플리케이션에서 생성한 객체가 저장됨 (Eden, Survivor, Old Gen) |
| **Non-Heap** | 클래스 메타데이터, 코드 캐시, JIT 컴파일된 코드, 스레드 스택 등이 저장됨 |

📌 **Non-Heap 메모리는 직접적인 객체 저장소가 아니라, JVM 내부 동작을 위한 메모리 공간이야!**  
📌 **Heap과 달리 GC(가비지 컬렉션)으로 자동 정리되지 않기 때문에, 과도한 사용은 메모리 부족으로 이어질 수 있어.**

---

## 🔹 예제
| 메트릭 | 값 (Bytes) |
|---------|------------|
| `jvm_memory_used_bytes` | 500,000,000 (500MB) |
| `jvm_memory_max_bytes` | 1,000,000,000 (1GB) |

```math
(500,000,000 * 100) / 1,000,000,000 = 50%
```
📌 **결과: 현재 Non-Heap 메모리 사용률은 `50%`**

---

## 🔥 왜 모니터링해야 할까?
✔ **Non-Heap 사용률이 높으면?**
- **메타데이터, 코드 캐시가 과도하게 사용됨 → JVM의 성능 저하 가능성**
- **JIT 컴파일된 코드 증가 → CodeCache 메모리 부족으로 성능 저하 발생 가능**
- **클래스 로딩이 많을 경우 Metaspace 부족 → 애플리케이션 충돌 가능**

✔ **Non-Heap 사용률이 낮으면?**
- **메모리가 충분히 확보됨 → JVM이 안정적으로 실행 중**
- **하지만 너무 낮다면 JVM 설정이 과도한 것일 수도 있음 (메모리 낭비 가능성 존재)**

---

## 📌 Grafana에서 Non-Heap 메모리 모니터링 대시보드 설정
### 🖥️ 패널 설정
- **패널 유형:** Line Chart
- **X축:** 시간 (Timestamp)
- **Y축:** Non-Heap 메모리 사용률 (%)
- **Y축 단위 변경:** Percent (`percent (0-100)`)
- **PromQL 쿼리:**
```promql
sum(jvm_memory_used_bytes{area="nonheap"}) * 100 / sum(jvm_memory_max_bytes{area="nonheap"})
```

### 🚨 임계값(Threshold) 설정
- **90% 이상** → 🔴 **위험 (Non-Heap OOM 발생 가능성 높음)**
- **80~90%** → 🟠 **주의 (CodeCache 부족 가능성)**
- **50~80%** → 🟢 **정상**
- **50% 이하** → 🔵 **메모리 여유 있음**

---

## ✅ 결론
- **JVM Non-Heap 사용량을 %로 계산하여 실시간으로 모니터링 가능.**
- **Non-Heap 사용률이 90% 이상 지속되면 JVM 내부 동작에 문제가 발생할 가능성이 있음 → 적극적인 관리 필요!**
- **Grafana에서 Non-Heap 메모리 사용 패턴을 분석하고 JVM 튜닝에 활용할 수 있음.**
</details>

<details>
<summary><strong>JVM CPU 사용률 모니터링</strong></summary>
# 📌 JVM CPU 사용률 모니터링

## 📊 PromQL 쿼리
### **1. 시스템 전체 CPU 사용률**
```promql
system_cpu_usage{instance="$instance", application="$application"}
```
✔ **시스템(OS)에서 전체 CPU 사용량을 측정하는 지표.**  
✔ **서버 전체(운영체제 기준)의 CPU 사용률을 나타냄.**  
✔ **애플리케이션 외에도, 다른 프로세스들이 얼마나 CPU를 점유하는지 파악 가능.**

### **2. 프로세스(JVM) CPU 사용률**
```promql
process_cpu_usage{instance="$instance", application="$application"}
```
✔ **JVM 프로세스(애플리케이션) 자체가 사용하고 있는 CPU 사용률을 측정하는 지표.**  
✔ **JVM만 얼마나 CPU를 점유하고 있는지 파악 가능.**  
✔ **이 값을 모니터링하면 특정 애플리케이션의 CPU 사용량 이상 감지를 할 수 있음.**

---

## 🔍 설명
| **쿼리** | **설명** |
|----------|---------|
| `system_cpu_usage` | 서버 전체의 CPU 사용률 (운영체제 기준) |
| `process_cpu_usage` | JVM 프로세스의 CPU 사용률 (애플리케이션 기준) |

📌 **이 두 지표를 함께 보면 JVM이 서버 자원을 얼마나 점유하는지 비교 가능!**  
📌 **서버 과부하가 JVM 때문인지, 다른 프로세스 때문인지 쉽게 분석 가능!**

---

## 🔥 왜 Tooltip에 Mean, Last*, Max, Min을 추가해야 할까?
📌 **Grafana Tooltip에서 Mean, Last, Max, Min 값을 출력하면 CPU 사용량의 변화를 쉽게 파악할 수 있음.**

### ✅ **1. Mean (평균)**
✔ **평균 CPU 사용률을 확인하면 전체적인 트렌드를 볼 수 있음.**  
✔ **일시적인 스파이크가 아닌, 지속적인 CPU 점유율을 확인하는 데 유용.**

### ✅ **2. Last* (마지막 측정값)**
✔ **실시간 모니터링에 필수적인 값.**  
✔ **현재 시점에서 CPU 사용량이 정상인지, 과부하인지 판단하는 데 중요.**

### ✅ **3. Max (최대값)**
✔ **일정 기간 동안 CPU 사용률이 가장 높았던 순간을 확인 가능.**  
✔ **CPU 과부하가 발생한 피크 타임을 분석할 수 있음.**

### ✅ **4. Min (최소값)**
✔ **CPU 사용량이 가장 낮았던 순간을 확인하여, 리소스 활용 효율을 점검할 수 있음.**  
✔ **불필요한 리소스 사용이 없는지 분석하는 데 유용.**

📌 **Mean, Last*, Max, Min을 함께 보면 단순히 현재 CPU 사용량뿐만 아니라, 변동 패턴과 이상치를 쉽게 감지 가능!**

---

## 📌 Grafana에서 CPU 사용률 모니터링 대시보드 설정
### 🖥️ 패널 설정
- **패널 유형:** Line Chart
- **X축:** 시간 (Timestamp)
- **Y축:** CPU 사용률 (%)
- **Y축 단위 변경:** Percent (`percent (0-100)`)
- **PromQL 쿼리:**
    - **시스템 전체 CPU 사용률**
      ```promql
      system_cpu_usage{instance="$instance", application="$application"}
      ```
    - **JVM 프로세스 CPU 사용률**
      ```promql
      process_cpu_usage{instance="$instance", application="$application"}
      ```

### 🚨 임계값(Threshold) 설정
- **90% 이상** → 🔴 **위험 (CPU 과부하 가능성 높음)**
- **80~90%** → 🟠 **주의 (CPU 사용량 증가)**
- **50~80%** → 🟢 **정상**
- **50% 이하** → 🔵 **CPU 여유 있음**

---

## ✅ 결론
✔ **`system_cpu_usage`와 `process_cpu_usage`를 함께 보면 JVM이 서버 전체 CPU에서 차지하는 비율을 파악 가능!**  
✔ **서버 CPU 과부하가 JVM 때문인지, 다른 시스템 프로세스 때문인지 쉽게 분석 가능!**  
✔ **Grafana Tooltip에 Mean, Last*, Max, Min을 추가하면 CPU 변동 패턴을 상세히 분석할 수 있음!**  
✔ **JVM의 CPU 사용량이 90% 이상 지속되면 CPU 스로틀링이나 성능 이슈가 발생할 가능성이 높음 → 적극적인 모니터링 필요!**

</details>

<details>
<summary><strong>JVM Load Average 및 CPU 코어 수 모니터링</strong></summary>
# 📌 JVM Load Average 및 CPU 코어 수 모니터링

## 📊 PromQL 쿼리
### **1. 시스템 Load Average (1분 평균)**
```promql
system_load_average_1m{instance="$instance", application="$application"}
```
✔ **운영체제(OS)의 Load Average(1분 평균) 값을 측정하는 지표.**  
✔ **Load Average는 현재 실행 중이거나 실행 대기 중인 프로세스의 수를 나타냄.**  
✔ **CPU의 작업 부하를 측정하여 시스템이 과부하 상태인지 판단하는 데 도움됨.**

### **2. 시스템 CPU 코어 개수**
```promql
system_cpu_count{instance="$instance", application="$application"}
```
✔ **서버(인스턴스)에 할당된 물리적/논리적 CPU 코어 개수를 측정하는 지표.**  
✔ **Load Average 값을 정확하게 해석하기 위해 필수적인 지표.**  
✔ **CPU 개수 대비 Load Average가 너무 높으면 시스템이 과부하 상태일 가능성이 높음.**

---

## 🔍 설명
| **쿼리** | **설명** |
|----------|---------|
| `system_load_average_1m` | 1분 동안의 평균 Load 값을 측정 |
| `system_cpu_count` | 시스템에서 사용 가능한 CPU 코어 개수 |

📌 **Load Average는 단독으로 보면 의미가 없고, CPU 코어 개수와 함께 비교해야 함!**  
📌 **CPU 개수보다 Load Average가 높다면 시스템이 과부하 상태일 가능성이 높음.**

---

## 🔥 Load Average와 CPU 개수 비교의 중요성
### ✅ Load Average 값 해석 방법
✔ **Load Average 값이 CPU 개수보다 낮으면?**
- 시스템이 여유롭게 운영 중
- CPU에 충분한 리소스가 있음

✔ **Load Average 값이 CPU 개수보다 크면?**
- CPU에 대기 중인 프로세스가 많음
- CPU 병목 가능성이 있음 → 성능 저하 발생 가능

✔ **Load Average 값이 CPU 개수의 2~3배 이상이면?**
- 시스템이 과부하 상태 (CPU 한계 초과)
- 추가적인 리소스 확장 필요

---

## 📌 Grafana에서 Load Average & CPU 개수 모니터링 대시보드 설정
### 🖥️ 패널 설정
- **패널 유형:** Line Chart
- **X축:** 시간 (Timestamp)
- **Y축:** Load Average 및 CPU 개수 (비교)
- **Y축 단위 변경:** None (`unitless`)
- **PromQL 쿼리:**
    - **Load Average (1m)**
      ```promql
      system_load_average_1m{instance="$instance", application="$application"}
      ```
    - **CPU 코어 개수 (수평 기준선으로 표시)**
      ```promql
      system_cpu_count{instance="$instance", application="$application"}
      ```

### 🚨 임계값(Threshold) 설정
- **Load Average가 CPU 개수보다 낮음** → 🟢 **정상**
- **Load Average가 CPU 개수와 같음 (~ 1.5배 이내)** → 🟠 **주의 (CPU 사용률 증가 가능성 있음)**
- **Load Average가 CPU 개수의 2배 이상** → 🔴 **위험 (CPU 과부하 가능성 높음)**

📌 **Load Average가 CPU 개수를 초과하면 스레드 풀 설정, 성능 최적화 또는 서버 증설 고려해야 함.**

---

## ✅ 결론
✔ **Load Average는 단독으로 보면 의미가 없고, 반드시 CPU 개수와 비교해야 함!**  
✔ **CPU 개수보다 Load Average가 높다면, 시스템이 과부하 상태일 가능성이 높음!**  
✔ **Grafana에서 Load Average와 CPU 개수를 함께 모니터링하면 성능 병목을 미리 감지 가능!**

</details>



<details>
<summary><strong>JVM 열린 파일 핸들 개수 모니터링</strong></summary>
# 📌 JVM 열린 파일 핸들 개수 모니터링

## 📊 PromQL 쿼리
### **1. 현재 열린 파일 핸들 개수**
```promql
process_files_open_files{application="$application", instance="$instance"}
```
✔ **현재 JVM 프로세스에서 열고 있는 파일 핸들의 개수를 측정하는 지표.**  
✔ **파일 핸들은 소켓, 로그 파일, DB 연결, 일반 파일 등을 포함할 수 있음.**  
✔ **운영체제의 리소스 제한을 초과하면 "Too many open files" 오류 발생 가능.**

### **2. JVM이 열 수 있는 최대 파일 핸들 개수**
```promql
process_files_max_files{application="$application", instance="$instance"}
```
✔ **JVM 프로세스가 열 수 있는 최대 파일 핸들 개수를 측정하는 지표.**  
✔ **운영체제(OS)의 `ulimit -n` 설정 값과 관련 있음.**  
✔ **이 값을 초과하면 추가적인 파일 핸들 생성이 불가능해짐.**

---

## 🔍 설명
| **쿼리** | **설명** |
|----------|---------|
| `process_files_open_files` | 현재 JVM 프로세스가 열고 있는 파일 핸들 개수 |
| `process_files_max_files` | 운영체제(OS)에서 허용하는 최대 파일 핸들 개수 |

📌 **운영체제는 하나의 프로세스에서 열 수 있는 파일 핸들 수를 제한함!**  
📌 **이 값을 초과하면 `Too many open files` 오류가 발생하여 애플리케이션이 정상적으로 동작하지 않을 수 있음.**

---

## 🔥 왜 중요한가?
### ✅ 파일 핸들 개수가 중요한 이유
✔ **JVM이 너무 많은 파일을 열고 있으면?**
- 리소스 누수 가능성 (파일 닫기 미처리)
- `Too many open files` 오류 발생 가능
- DB Connection, 소켓 연결 등 시스템 자원 부족

✔ **운영체제에서 허용하는 파일 핸들 개수가 너무 낮으면?**
- JVM이 필요한 만큼의 파일을 열 수 없음
- `ulimit -n` 설정이 낮아 서비스 장애 발생 가능
- 특정 애플리케이션(예: 파일 기반 DB, 로깅 시스템)에서 문제 발생 가능

📌 **파일 핸들 개수는 JVM 성능과 안정성에 직접적인 영향을 미침!**

---

## 📌 Grafana에서 파일 핸들 개수 모니터링 대시보드 설정
### 🖥️ 패널 설정
- **패널 유형:** Line Chart
- **X축:** 시간 (Timestamp)
- **Y축:** 열린 파일 핸들 개수 및 최대 파일 핸들 개수
- **Y축 단위 변경:** None (`unitless`)
- **PromQL 쿼리:**
    - **현재 열린 파일 핸들 개수**
      ```promql
      process_files_open_files{instance="$instance", application="$application"}
      ```
    - **최대 허용 파일 핸들 개수**
      ```promql
      process_files_max_files{instance="$instance", application="$application"}
      ```

### 🚨 임계값(Threshold) 설정
- **열린 파일 핸들 개수가 최대 파일 핸들 개수의 80% 이하** → 🟢 **정상**
- **열린 파일 핸들 개수가 최대 값의 80~90%** → 🟠 **주의 (파일 핸들 사용량 증가)**
- **열린 파일 핸들 개수가 최대 값의 90% 이상** → 🔴 **위험 (파일 핸들 부족 가능성 높음)**

📌 **파일 핸들 사용량이 90%를 초과하면 JVM 설정 또는 `ulimit -n` 값을 조정해야 함!**

---

## ✅ 결론
✔ **JVM이 열고 있는 파일 핸들 개수(`process_files_open_files`)가 운영체제 허용 값(`process_files_max_files`)을 초과하면 장애 발생 가능!**  
✔ **파일 핸들 누수가 있으면, 시스템 성능 저하 및 서비스 불안정 가능성이 있음!**  
✔ **Grafana에서 열린 파일 핸들 개수와 허용 가능한 최대 개수를 함께 모니터링하면 서비스 장애를 미연에 방지 가능!**

📌 **이제 이 설정을 적용하여 JVM의 파일 핸들 상태를 효과적으로 관리하자! 🚀**

</details>

