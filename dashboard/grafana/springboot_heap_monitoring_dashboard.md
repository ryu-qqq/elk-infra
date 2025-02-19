<details>
<summary><strong>G1 Eden Space, G1 Old Gen, G1 Survivor Space (Heap) 모니터링</strong></summary>
# 📌 (Heap) G1 Eden Space, G1 Old Gen, G1 Survivor Space 모니터링

## 📊 PromQL 쿼리
### **1. 현재 사용 중인 메모리 (Used)**
```promql
jvm_memory_used_bytes{instance="$instance", application="$application", id="$memory_pool_heap"}
```
✔ **현재 G1 Eden Space에서 사용 중인 메모리 크기 (Bytes).**  
✔ **새롭게 생성된 객체가 할당되는 공간.**  
✔ **Garbage Collection(GC) 전까지 사용되는 메모리를 측정.**

### **2. 할당된(Committed) 메모리 크기**
```promql
jvm_memory_committed_bytes{instance="$instance", application="$application", id="$memory_pool_heap"}
```
✔ **현재 JVM이 OS로부터 확보한 메모리 크기 (Bytes).**  
✔ **이 크기까지는 객체를 저장할 수 있으며, 필요 시 증가 가능.**  
✔ **최대 메모리(`max_bytes`)보다 작을 수도 있음.**

### **3. 최대(Maxed) 메모리 크기**
```promql
jvm_memory_max_bytes{instance="$instance", application="$application", id="$memory_pool_heap"}
```
✔ **JVM이 사용할 수 있는 최대 G1 Eden Space 메모리 크기 (Bytes).**  
✔ **이 값을 초과하면 GC가 발생하거나 OOM(Out of Memory) 에러 발생 가능.**  
✔ **`-Xmx` 옵션에 의해 설정됨.**

---

## 🔍 설명
| **쿼리** | **설명** |
|----------|---------|
| `jvm_memory_used_bytes` | 현재 사용 중인 메모리 크기 |
| `jvm_memory_committed_bytes` | 현재 JVM이 확보한 메모리 크기 |
| `jvm_memory_max_bytes` | JVM이 사용할 수 있는 최대 메모리 크기 |

📌 **사용 중(Used) 메모리 값만 보면 안 되고, 확보(Committed)된 값과 비교해야 메모리 사용 패턴을 분석할 수 있음!**  
📌 **최대(Max) 값과 비교하여 GC가 적절히 발생하는지 확인해야 OOM을 방지할 수 있음.**

---

## 🔥 왜 이 3개의 메트릭이 필요한가?
✔ **`Used`만 보면 안 되는 이유**
- 사용량이 많다고 해서 즉시 문제가 되는 것은 아님.
- Committed 값과 비교하여 JVM이 적절히 메모리를 확보하고 있는지 확인해야 함.

✔ **`Committed` 값을 보는 이유**
- 사용량(`Used`)이 증가할 때, JVM이 확보한 메모리(`Committed`)가 같이 증가하는지 확인.
- JVM이 확보한 메모리가 너무 작다면, 메모리 부족(OOM) 가능성 존재.

✔ **`Max` 값을 보는 이유**
- JVM이 확보할 수 있는 최대 메모리 크기와 비교하여 GC가 잘 발생하는지 분석.
- 최대 값(`Max`)까지 사용량(`Used`)이 도달하면, GC 또는 메모리 최적화 필요.

---

## 📌 Grafana에서 G1 Eden Space 모니터링 대시보드 설정
### 🖥️ 패널 설정
- **패널 유형:** Line Chart
- **X축:** 시간 (Timestamp)
- **Y축:** 메모리 사용량 (Bytes)
- **Y축 단위 변경:** Bytes (`bytes`)
- **PromQL 쿼리:**
    - **현재 사용 중인 메모리**
      ```promql
      jvm_memory_used_bytes{instance="$instance", application="$application", id="$memory_pool_heap"}
      ```
    - **현재 확보(Committed)된 메모리**
      ```promql
      jvm_memory_committed_bytes{instance="$instance", application="$application", id="$memory_pool_heap"}
      ```
    - **최대(Max) 메모리**
      ```promql
      jvm_memory_max_bytes{instance="$instance", application="$application", id="$memory_pool_heap"}
      ```

### 🚨 임계값(Threshold) 설정
- **Used가 Committed의 80% 이상** → 🟠 **주의 (메모리 부족 가능성)**
- **Used가 Max에 도달** → 🔴 **위험 (OOM 가능성 높음, GC 최적화 필요)**
- **Used가 Committed보다 낮음** → 🟢 **정상 (JVM이 적절히 메모리를 관리 중)**

📌 **GC가 자주 발생하면 사용량(`Used`)이 급격히 줄어드는지 확인해야 함!**  
📌 **Used가 Max에 도달하면 JVM 설정(`-Xmx`)을 재조정해야 할 수도 있음.**

---

## ✅ 결론
✔ **Used(사용량), Committed(확보량), Max(최대량)를 함께 보면 JVM이 메모리를 어떻게 사용하고 있는지 알 수 있음!**  
✔ **메모리 부족(OOM) 가능성을 사전에 감지하고, JVM GC 최적화를 수행 가능!**  
✔ **Grafana에서 메모리 사용량 변화를 실시간으로 모니터링하여 성능 튜닝에 활용 가능!**

</details>



<details>
<summary><strong> Compressed Class Space (Non-Heap) 모니터링</strong></summary>

# 📌 Compressed Class Space (Non-Heap) 모니터링

## 📊 PromQL 쿼리
### **1. 현재 사용 중인 메모리 (Used)**
```promql
jvm_memory_used_bytes{instance="$instance", application="$application", id="Compressed Class Space"}
```
✔ **JVM의 Compressed Class Space에서 현재 사용 중인 메모리 크기 (Bytes).**  
✔ **메타데이터(클래스 정보, 메서드 정의 등)를 저장하는 영역.**  
✔ **클래스 로딩이 증가하면 사용량이 증가함.**

### **2. 할당된(Committed) 메모리 크기**
```promql
jvm_memory_committed_bytes{instance="$instance", application="$application", id="Compressed Class Space"}
```
✔ **JVM이 OS로부터 확보한 메모리 크기 (Bytes).**  
✔ **클래스 로딩 및 메타데이터 저장을 위해 미리 확보된 메모리.**  
✔ **최대 메모리(`max_bytes`)보다 작을 수도 있음.**

### **3. 최대(Max) 메모리 크기**
```promql
jvm_memory_max_bytes{instance="$instance", application="$application", id="Compressed Class Space"}
```
✔ **JVM이 사용할 수 있는 Compressed Class Space의 최대 크기 (Bytes).**  
✔ **클래스 로딩이 많아지면 이 값에 도달할 수 있음.**  
✔ **이 값을 초과하면 `OutOfMemoryError: Metaspace` 발생 가능.**

---

## 🔍 설명
| **쿼리** | **설명** |
|----------|---------|
| `jvm_memory_used_bytes` | 현재 사용 중인 Compressed Class Space 메모리 크기 |
| `jvm_memory_committed_bytes` | 현재 JVM이 확보한 Compressed Class Space 메모리 크기 |
| `jvm_memory_max_bytes` | JVM이 사용할 수 있는 최대 Compressed Class Space 메모리 크기 |

📌 **Compressed Class Space는 Java 8부터 Metaspace로 통합되었으며, JVM의 클래스 로딩과 밀접한 관계가 있음.**  
📌 **클래스 로딩이 많거나 동적 클래스 로딩이 많을 경우 사용량이 급격히 증가할 수 있음.**

---

## 🔥 왜 이 3개의 메트릭이 필요한가?
✔ **`Used`만 보면 안 되는 이유**
- 사용량이 많다고 해서 즉시 문제가 되는 것은 아님.
- Committed 값과 비교하여 JVM이 적절히 메모리를 확보하고 있는지 확인해야 함.

✔ **`Committed` 값을 보는 이유**
- 사용량(`Used`)이 증가할 때, JVM이 확보한 메모리(`Committed`)가 같이 증가하는지 확인.
- JVM이 확보한 메모리가 너무 작다면, Metaspace 부족(OOM) 가능성 존재.

✔ **`Max` 값을 보는 이유**
- JVM이 확보할 수 있는 최대 메모리 크기와 비교하여 Metaspace가 잘 동작하는지 분석.
- 최대 값(`Max`)까지 사용량(`Used`)이 도달하면, GC 또는 Metaspace 크기 조정 필요.

---

## 📌 Grafana에서 Compressed Class Space 모니터링 대시보드 설정
### 🖥️ 패널 설정
- **패널 유형:** Line Chart
- **X축:** 시간 (Timestamp)
- **Y축:** 메모리 사용량 (Bytes)
- **Y축 단위 변경:** Bytes (`bytes`)
- **PromQL 쿼리:**
    - **현재 사용 중인 메모리**
      ```promql
      jvm_memory_used_bytes{instance="$instance", application="$application", id="Compressed Class Space"}
      ```
    - **현재 확보(Committed)된 메모리**
      ```promql
      jvm_memory_committed_bytes{instance="$instance", application="$application", id="Compressed Class Space"}
      ```
    - **최대(Max) 메모리**
      ```promql
      jvm_memory_max_bytes{instance="$instance", application="$application", id="Compressed Class Space"}
      ```

### 🚨 임계값(Threshold) 설정
- **Used가 Committed의 80% 이상** → 🟠 **주의 (Metaspace 부족 가능성)**
- **Used가 Max에 도달** → 🔴 **위험 (OOM 가능성 높음, Metaspace 크기 조정 필요)**
- **Used가 Committed보다 낮음** → 🟢 **정상 (JVM이 적절히 메모리를 관리 중)**

📌 **Metaspace가 부족하면, `OutOfMemoryError: Metaspace` 발생 가능!**  
📌 **Spring Boot와 같은 프레임워크에서는 동적 클래스 로딩이 많아 Metaspace 사용량이 예상보다 많을 수 있음.**

---

## ✅ 결론
✔ **Used(사용량), Committed(확보량), Max(최대량)를 함께 보면 JVM이 Compressed Class Space를 어떻게 관리하는지 알 수 있음!**  
✔ **메모리 부족(OOM) 가능성을 사전에 감지하고, JVM Metaspace 크기를 조정할 수 있음!**  
✔ **Grafana에서 Compressed Class Space 사용량 변화를 실시간으로 모니터링하여 성능 최적화 가능!**

</details>

<details>
<summary><strong> Metaspace (Non-Heap) 모니터링</strong></summary>

# 📌 Metaspace (Non-Heap) 모니터링

## 📊 PromQL 쿼리
### **1. 현재 사용 중인 Metaspace 메모리 (Used)**
```promql
jvm_memory_used_bytes{instance="$instance", application="$application", id="Metaspace"}
```
✔ **JVM의 Metaspace에서 현재 사용 중인 메모리 크기 (Bytes).**  
✔ **클래스 메타데이터를 저장하는 공간.**  
✔ **클래스 로딩이 많아질수록 사용량 증가.**

### **2. 할당된(Committed) Metaspace 메모리 (Committed)**
```promql
jvm_memory_committed_bytes{instance="$instance", application="$application", id="Metaspace"}
```
✔ **JVM이 OS에서 확보한 Metaspace 크기 (Bytes).**  
✔ **Used 값과 비교하여 JVM이 적절히 메모리를 관리하는지 확인.**

### **3. 최대(Max) Metaspace 메모리 (Max)**
```promql
jvm_memory_max_bytes{instance="$instance", application="$application", id="Metaspace"}
```
✔ **JVM이 사용할 수 있는 Metaspace의 최대 크기 (Bytes).**  
✔ **이 값을 초과하면 `OutOfMemoryError: Metaspace` 오류 발생 가능.**  
✔ **`-XX:MaxMetaspaceSize` 값과 연관됨.**

---

## 🔍 설명
| **쿼리** | **설명** |
|----------|---------|
| `jvm_memory_used_bytes` | 현재 사용 중인 Metaspace 메모리 크기 |
| `jvm_memory_committed_bytes` | 현재 JVM이 확보한 Metaspace 크기 |
| `jvm_memory_max_bytes` | JVM이 사용할 수 있는 최대 Metaspace 크기 |

📌 **Metaspace는 Java 8부터 PermGen을 대체하며, JVM의 클래스 로딩과 밀접한 관계가 있음.**  
📌 **클래스 로딩이 많거나 동적 클래스 로딩이 많을 경우 사용량이 급격히 증가할 수 있음.**

---

## 🔥 왜 Metaspace 모니터링이 중요한가?
✔ **클래스 로딩이 많아지면 메모리 부족(OOM) 가능성 증가**
- Java에서는 **클래스가 로드될 때마다 Metaspace 사용량이 증가**함.
- Spring Boot, Hibernate, Reflection 기반 프레임워크에서 **동적 클래스 로딩**이 많으면 Metaspace 사용량이 급증할 수 있음.
- Metaspace가 **최대 크기(`Max`)에 도달하면**,  
  `OutOfMemoryError: Metaspace` 오류가 발생할 수 있음.

✔ **클래스 언로드가 지연되면 메모리 누수 가능**
- **클래스 로딩(ClassLoader)이 해제되지 않으면, 메타데이터가 계속 Metaspace에 남음.**
- 동적 클래스 로딩이 많은 시스템에서는 **메모리 누수 가능성이 높아짐**.

✔ **JVM 설정 최적화를 위한 분석**
- Metaspace는 기본적으로 **OS에서 동적으로 크기를 조정**하지만, **무제한으로 확장되지는 않음.**
- `-XX:MaxMetaspaceSize` 옵션으로 최대 크기를 설정할 수 있음.
- **메모리 사용 패턴을 분석하여 적절한 MaxMetaspaceSize 값을 설정해야 함.**
- **Spring Boot 서비스에서 실행 시간이 길어질수록 Metaspace 증가량을 모니터링**해야 함.

---

## 📌 Grafana에서 Metaspace 모니터링 대시보드 설정
### 🖥️ 패널 설정
- **패널 유형:** Line Chart
- **X축:** 시간 (Timestamp)
- **Y축:** 메모리 사용량 (Bytes)
- **Y축 단위 변경:** Bytes (`bytes`)
- **PromQL 쿼리:**
    - **현재 사용 중인 메모리**
      ```promql
      jvm_memory_used_bytes{instance="$instance", application="$application", id="Metaspace"}
      ```
    - **현재 확보(Committed)된 메모리**
      ```promql
      jvm_memory_committed_bytes{instance="$instance", application="$application", id="Metaspace"}
      ```
    - **최대(Max) 메모리**
      ```promql
      jvm_memory_max_bytes{instance="$instance", application="$application", id="Metaspace"}
      ```

### 🚨 임계값(Threshold) 설정
- **Used가 Committed의 80% 이상** → 🟠 **주의 (Metaspace 부족 가능성)**
- **Used가 Max에 도달** → 🔴 **위험 (OOM 가능성 높음, MaxMetaspaceSize 조정 필요)**
- **Used가 Committed보다 낮음** → 🟢 **정상 (JVM이 적절히 메모리를 관리 중)**

📌 **클래스 로딩이 많을 경우 Metaspace가 예상보다 빨리 증가할 수 있음!**  
📌 **Spring Boot, Hibernate, JPA 환경에서는 동적 클래스 로딩을 고려하여 Metaspace 사용량을 모니터링해야 함!**

---

## ✅ 결론
✔ **Metaspace는 Java 클래스 메타데이터를 저장하는 공간이며, OOM 발생 가능성이 있음.**  
✔ **클래스 로딩이 많을수록 Metaspace 사용량이 증가하여 OutOfMemoryError 위험이 있음.**  
✔ **JVM 설정(`-XX:MaxMetaspaceSize`)을 조정하고, Metaspace 사용량을 실시간 모니터링해야 안정적인 서비스 운영 가능!**

</details>


<details>
<summary> JVM 스레드(Thread) 모니터링 </summary>

# 📌 JVM 스레드(Thread) 모니터링

## 📊 PromQL 쿼리
### **1. 현재 실행 중인 데몬 스레드 개수 (Daemon Threads)**
```promql
jvm_threads_daemon_threads{instance="$instance", application="$application"}
```
✔ **JVM에서 실행 중인 데몬(daemon) 스레드의 개수**  
✔ **데몬 스레드는 주 스레드가 종료되면 자동으로 정리됨.**  
✔ **백그라운드 작업 (Garbage Collector, 메모리 관리 등) 수행.**  
✔ **이 값이 갑자기 증가하거나 감소하면 애플리케이션이 비정상적으로 동작하는 신호일 수 있음.**

### **2. 현재 실행 중인 전체 스레드 개수 (Live Threads)**
```promql
jvm_threads_live_threads{instance="$instance", application="$application"}
```
✔ **현재 실행 중인 전체 스레드 개수 (Daemon + Non-Daemon 포함).**  
✔ **애플리케이션의 동시 요청 처리량과 직접적인 연관이 있음.**  
✔ **스레드 개수가 급격히 증가하면 CPU 사용량 증가 및 응답 지연 발생 가능.**  
✔ **갑작스러운 급증이 발생하면, 스레드 풀(Thread Pool) 설정을 점검해야 함.**

### **3. 피크(최대) 스레드 개수 (Peak Threads)**
```promql
jvm_threads_peak_threads{instance="$instance", application="$application"}
```
✔ **JVM이 실행된 이후 가장 높은 스레드 개수 (최대값 기록).**  
✔ **애플리케이션이 과거에 몇 개의 스레드를 생성했는지 확인 가능.**  
✔ **지속적으로 높은 값이면, 과도한 스레드 사용을 의심할 필요가 있음.**  
✔ **스레드 누수(Thread Leak) 감지 및 부하 테스트 결과 분석에 유용.**

---

## 🔍 설명
| **쿼리** | **설명** |
|----------|---------|
| `jvm_threads_daemon_threads` | 현재 실행 중인 **데몬 스레드 개수** |
| `jvm_threads_live_threads` | 현재 실행 중인 **전체 스레드 개수** |
| `jvm_threads_peak_threads` | JVM이 기록한 **최대 스레드 개수** |

📌 **스레드 개수가 갑자기 증가하면, CPU 과부하나 메모리 문제 발생 가능!**  
📌 **Peak Threads 값을 참고하면, 서버의 최대 부하 상태를 예측할 수 있음!**  
📌 **Live Threads 개수가 비정상적으로 높은 경우, 스레드 풀(Thread Pool) 조정이 필요함.**

---

## 🔥 왜 이 3개의 메트릭이 필요한가?
✔ **데몬 스레드(Daemon Threads)만 봐서는 안 되는 이유**
- 데몬 스레드는 백그라운드 작업을 수행하는데,  
  애플리케이션의 성능 문제를 일으키는 건 대부분 **Non-Daemon(비-데몬) 스레드**야.
- 따라서 **전체 스레드 개수(Live Threads)**도 함께 확인해야 함.

✔ **현재 실행 중인 전체 스레드 개수를 보는 이유**
- 애플리케이션의 부하 상태를 분석할 수 있음.
- 갑작스럽게 **Live Threads**가 증가하면,  
  **스레드 누수(Thread Leak) 또는 비효율적인 스레드 생성 가능성**이 있음.

✔ **Peak Threads를 보는 이유**
- 스레드 개수가 얼마나 증가했는지 확인 가능.
- 과거 기록을 통해 부하 테스트 및 성능 분석 가능.
- 스레드가 일정 이상 증가한 후 줄어들지 않으면,  
  **Thread Pool 설정이 잘못되었거나, 스레드가 적절히 종료되지 않는 문제**가 있을 수 있음.

---

## 📌 Grafana에서 JVM 스레드 모니터링 대시보드 설정
### 🖥️ 패널 설정
- **패널 유형:** Line Chart
- **X축:** 시간 (Timestamp)
- **Y축:** 스레드 개수 (Count)
- **PromQL 쿼리:**
    - **현재 실행 중인 데몬 스레드 개수**
      ```promql
      jvm_threads_daemon_threads{instance="$instance", application="$application"}
      ```
    - **현재 실행 중인 전체 스레드 개수**
      ```promql
      jvm_threads_live_threads{instance="$instance", application="$application"}
      ```
    - **최대(피크) 스레드 개수**
      ```promql
      jvm_threads_peak_threads{instance="$instance", application="$application"}
      ```

### 🚨 임계값(Threshold) 설정
- **Live Threads가 500개 이상** → 🟠 **주의 (부하 증가 감지)**
- **Live Threads가 1000개 이상** → 🔴 **위험 (스레드 풀 초과 가능성)**
- **Peak Threads가 지속적으로 높은 값 유지** → 🔴 **스레드 누수 가능성, 서버 리소스 점검 필요**
- **Daemon Threads가 급감** → 🟠 **백그라운드 작업 실패 가능성**

📌 **Live Threads가 급증하면, CPU 사용률 및 GC 활동도 함께 점검해야 함!**  
📌 **Peak Threads 값이 지나치게 높으면, 부하 테스트 시점을 확인하고 설정 조정이 필요함.**

---

## ✅ 결론
✔ **Daemon, Live, Peak 스레드를 모두 확인해야 JVM의 스레드 상태를 정확히 분석 가능!**  
✔ **Live Threads 개수가 많으면 스레드 풀(Thread Pool) 설정을 조정해야 함!**  
✔ **Peak Threads 값이 너무 높으면, 스레드 누수(Thread Leak) 가능성이 있음!**  
✔ **Grafana에서 스레드 개수를 모니터링하여 CPU 과부하 및 OOM 문제를 사전에 방지 가능!**


</details>

<details>
<summary> JVM GC 메모리 할당 및 승격 모니터링 </summary>

# 📌 JVM GC 메모리 할당 및 승격 모니터링

## 📊 PromQL 쿼리
### **1. 할당된 메모리 총량 (Allocated Memory)**
```promql
irate(jvm_gc_memory_allocated_bytes_total{instance="$instance", application="$application"}[5m])
```
✔ **JVM이 애플리케이션 실행 중에 새롭게 할당한 메모리의 총량.**  
✔ **Heap 영역에서 새 객체가 할당될 때마다 증가.**  
✔ **이 값이 급격히 증가하면, 객체 생성이 빈번하거나 GC가 충분히 수행되지 않는 신호일 수 있음.**  
✔ **애플리케이션의 메모리 사용 패턴을 파악하는 데 유용.**

### **2. 승격된 메모리 총량 (Promoted Memory)**
```promql
irate(jvm_gc_memory_promoted_bytes_total{instance="$instance", application="$application"}[5m])
```
✔ **Young Generation에서 Old Generation으로 이동한(승격된) 메모리의 총량.**  
✔ **Minor GC가 발생할 때 살아남은 객체들이 승격됨.**  
✔ **이 값이 지속적으로 높다면, Old Generation이 빠르게 채워지고 있음.**  
✔ **Old Generation의 크기 조정이나 GC 전략 변경이 필요한지 판단하는 데 도움.**

---

## 🔍 설명
| **쿼리** | **설명** |
|----------|---------|
| `jvm_gc_memory_allocated_bytes_total` | 새롭게 할당된 메모리의 총량 (바이트) |
| `jvm_gc_memory_promoted_bytes_total` | Young Generation에서 Old Generation으로 승격된 메모리의 총량 (바이트) |

📌 **메모리 할당(Allocation)과 승격(Promotion)의 비율이 GC 성능에 큰 영향을 미침.**  
📌 **할당 속도가 높은데 승격 속도가 낮다면, 대부분의 객체가 Young Generation에서 소멸하고 있다는 의미.**  
📌 **승격 속도가 높다면, Old Generation이 빨리 채워져서 Major GC 발생 가능성이 증가.**

---

## 🔥 **왜 이 2개의 메트릭이 중요한가?**
✔ **할당 메모리(Allocated Memory)만 보면 안 되는 이유**
- JVM이 새로운 객체를 빠르게 할당한다고 해서 반드시 문제가 되는 것은 아님.
- 승격 메모리(`Promoted Memory`)와 함께 보면 **객체가 얼마나 오래 살아남는지** 파악 가능.

✔ **승격 메모리(Promoted Memory)를 모니터링하는 이유**
- 승격이 많아지면 **Old Generation이 빠르게 채워져서 GC 빈도가 증가**할 수 있음.
- Old Generation이 가득 차면 **Major GC가 발생하여 애플리케이션의 응답 시간이 증가**할 가능성이 있음.

✔ **메모리 할당량과 승격량을 함께 보면 GC 최적화 가능**
- **할당 속도(Allocation Rate)**가 높은데 승격 속도는 낮다면, Young Generation에서 대부분 객체가 GC됨.
- **할당 속도와 승격 속도가 모두 높다면, GC 튜닝이 필요할 가능성이 높음.**

---

## 📌 **Grafana에서 JVM GC 메모리 모니터링 대시보드 설정**
### 🖥️ **패널 설정**
- **패널 유형:** Line Chart
- **X축:** 시간 (Timestamp)
- **Y축:** 메모리 크기 (Bytes)
- **PromQL 쿼리:**
    - **할당된 메모리 총량**
      ```promql
      irate(jvm_gc_memory_allocated_bytes_total{instance="$instance", application="$application"}[5m])
      ```
    - **승격된 메모리 총량**
      ```promql
      irate(jvm_gc_memory_promoted_bytes_total{instance="$instance", application="$application"}[5m])
      ```

### 🚨 **임계값(Threshold) 설정**
- **할당 속도가 급격히 증가** → 🟠 **주의 (객체 생성 빈도 증가, GC 부하 가능성)**
- **승격 속도가 높아짐** → 🔴 **위험 (Old Generation이 빠르게 채워짐, Major GC 가능성 증가)**
- **승격 속도가 거의 없음** → 🟢 **정상 (대부분의 객체가 Young Generation에서 GC됨)**

📌 **승격이 많아질 경우 GC 튜닝을 통해 Old Generation 크기 조정 필요!**  
📌 **JVM의 GC 로그(`-XX:+PrintGCDetails`)와 함께 모니터링하면 더욱 효과적인 분석 가능!**

---

## ✅ **결론**
✔ **메모리 할당량(Allocated Memory)과 승격량(Promoted Memory)을 함께 보면 JVM의 메모리 관리 상태를 파악 가능!**  
✔ **승격이 많아질수록 Major GC가 자주 발생할 가능성이 높음, 메모리 튜닝 필요!**  
✔ **Grafana에서 이 두 개의 메트릭을 실시간 모니터링하여 애플리케이션 성능을 최적화할 수 있음!**

</details>

<details>
<summary> JVM 클래스 로딩 및 언로딩 모니터링 </summary>

# 📌 JVM 클래스 로딩 및 언로딩 모니터링

## 📊 PromQL 쿼리
### **1. 현재 JVM에 로드된 클래스 개수 (Loaded Classes)**
```promql
jvm_classes_loaded_classes{instance="$instance", application="$application"}
```
✔ **현재 JVM에 로드된 클래스 개수.**  
✔ **애플리케이션 실행 중 동적으로 로드된 클래스의 총 개수를 나타냄.**  
✔ **Spring Boot, Reflection, Proxy 기반 기술을 사용할 경우 클래스 로딩 개수가 증가할 수 있음.**  
✔ **로드된 클래스 개수가 지속적으로 증가하면 메모리 문제(클래스 로딩 누수) 가능성이 있음.**

### **2. 언로드된 클래스 개수 변화율 (Unloaded Classes Rate)**
```promql
irate(jvm_classes_unloaded_classes_total{instance="$instance", application="$application"}[5m])
```
✔ **JVM에서 언로드된(제거된) 클래스 개수의 변화율.**  
✔ **클래스가 더 이상 필요하지 않을 때, JVM이 가비지 컬렉션과 함께 언로드 수행.**  
✔ **클래스 언로드가 거의 발생하지 않으면, 불필요한 클래스가 메모리에 계속 남아 있을 가능성이 있음.**  
✔ **이 값이 갑자기 증가하면, 동적 클래스 로딩이 많거나 리플렉션이 과도하게 사용될 가능성이 있음.**

---

## 🔍 설명
| **쿼리** | **설명** |
|----------|---------|
| `jvm_classes_loaded_classes` | 현재 JVM에 로드된 클래스 개수 |
| `jvm_classes_unloaded_classes_total` | JVM에서 언로드된 클래스 개수 변화율 |

📌 **클래스 로딩 및 언로딩이 JVM의 메모리 및 성능에 직접적인 영향을 미침.**  
📌 **클래스 로딩이 많아지면 PermGen(과거) 또는 Metaspace(Java 8 이후) 공간이 증가할 수 있음.**  
📌 **클래스 언로드가 적다면, 메모리 누수 가능성이 있음.**

---

## 🔥 **왜 이 2개의 메트릭이 중요한가?**
✔ **클래스 로딩 개수(Loaded Classes)만 보면 안 되는 이유**
- 애플리케이션 실행 중 새로운 클래스를 지속적으로 로드하는 경우,  
  JVM의 메모리 사용량이 증가할 가능성이 있음.
- 지속적인 증가 패턴이 있으면, **클래스 로딩 누수 가능성**이 있음.

✔ **클래스 언로딩(Unloaded Classes)을 모니터링해야 하는 이유**
- 클래스 언로드가 거의 발생하지 않으면, **불필요한 클래스를 JVM이 정리하지 못하고 있는 것**일 수 있음.
- 특히, **Reflection을 사용하여 동적 클래스를 많이 로딩하는 애플리케이션에서는 중요한 지표.**
- Spring AOP, Hibernate, Proxy 클래스들이 많이 생성되면 JVM이 계속해서 새로운 클래스를 로딩할 수 있음.

✔ **클래스 로딩과 언로딩을 함께 보면 JVM의 동작을 최적화 가능**
- **클래스 로딩 속도(Loaded Classes)**가 증가하는데 **클래스 언로드 속도(Unloaded Classes)**가 낮다면,  
  **Metaspace 또는 힙 메모리 사용량 증가 가능성이 있음.**
- **클래스 언로드가 급격히 증가하면, GC가 너무 자주 동작할 가능성이 있음.**

---

## 📌 **Grafana에서 JVM 클래스 로딩 모니터링 대시보드 설정**
### 🖥️ **패널 설정**
- **패널 유형:** Line Chart
- **X축:** 시간 (Timestamp)
- **Y축:** 클래스 개수 (Count)
- **PromQL 쿼리:**
    - **현재 JVM에 로드된 클래스 개수**
      ```promql
      jvm_classes_loaded_classes{instance="$instance", application="$application"}
      ```
    - **언로드된 클래스 개수 변화율**
      ```promql
      irate(jvm_classes_unloaded_classes_total{instance="$instance", application="$application"}[5m])
      ```

### 🚨 **임계값(Threshold) 설정**
- **Loaded Classes가 지속적으로 증가** → 🟠 **주의 (클래스 로딩 누수 가능성)**
- **Unloaded Classes가 거의 없음** → 🔴 **위험 (클래스가 메모리에 계속 남아 있을 가능성)**
- **Unloaded Classes가 급격히 증가** → 🟠 **GC 과부하 가능성**

📌 **동적 클래스 로딩이 많을 경우, JVM의 메모리 관리 정책을 점검해야 함!**  
📌 **Spring Boot와 같은 프레임워크에서는 Proxy 객체가 많아질수록 JVM이 지속적으로 클래스를 로딩할 가능성이 있음!**

---

## ✅ **결론**
✔ **클래스 로딩(Loaded Classes)과 클래스 언로딩(Unloaded Classes)을 함께 보면 JVM의 동작을 최적화 가능!**  
✔ **클래스 로딩이 많아지면 Metaspace 또는 힙 메모리 사용량 증가 가능성이 있음!**  
✔ **클래스 언로드가 거의 발생하지 않는다면, 불필요한 클래스가 메모리에 유지되는 문제 발생 가능!**  
✔ **Grafana에서 클래스 로딩/언로딩 모니터링을 통해 JVM의 메모리 및 성능을 최적화할 수 있음!**

</details>



<details>
<summary> JVM 버퍼(Buffer) 메모리 모니터링 </summary>
# 📌 JVM 버퍼(Buffer) 메모리 모니터링

## 📊 PromQL 쿼리
### **1. Direct Buffer 사용량 (Used Direct Buffer Memory)**
```promql
jvm_buffer_memory_used_bytes{instance="$instance", application="$application", id="direct"}
```
✔ **JVM에서 사용 중인 Direct Buffer 메모리 크기 (Bytes).**  
✔ **Direct Buffer는 OS 메모리를 직접 사용하며, 네트워크 및 파일 I/O에서 자주 활용됨.**  
✔ **이 값이 지속적으로 증가하면, Direct Buffer를 반환하지 않는 메모리 누수 가능성 있음.**

### **2. Direct Buffer 전체 용량 (Total Direct Buffer Capacity)**
```promql
jvm_buffer_total_capacity_bytes{instance="$instance", application="$application", id="direct"}
```
✔ **JVM이 확보한 Direct Buffer 전체 용량 (Bytes).**  
✔ **Used 값과 비교하여 메모리 사용 패턴을 분석할 수 있음.**  
✔ **Direct Buffer가 부족하면 성능 저하 및 GC 부하가 발생할 가능성이 있음.**

### **3. Mapped Buffer 사용량 (Used Mapped Buffer Memory)**
```promql
jvm_buffer_memory_used_bytes{instance="$instance", application="$application", id="mapped"}
```
✔ **JVM에서 사용 중인 Mapped Buffer 메모리 크기 (Bytes).**  
✔ **Mapped Buffer는 파일을 메모리에 매핑하여 처리할 때 사용됨.**  
✔ **대량의 파일을 처리하는 경우, 이 값이 높을 수 있음.**

### **4. Mapped Buffer 전체 용량 (Total Mapped Buffer Capacity)**
```promql
jvm_buffer_total_capacity_bytes{instance="$instance", application="$application", id="mapped"}
```
✔ **JVM이 확보한 Mapped Buffer 전체 용량 (Bytes).**  
✔ **사용된 Mapped Buffer와 비교하여 메모리 사용 패턴 분석 가능.**  
✔ **Mapped Buffer가 과도하게 증가하면 OS 메모리 부족 문제 발생 가능.**

---

## 🔍 설명
| **쿼리** | **설명** |
|----------|---------|
| `jvm_buffer_memory_used_bytes` | 현재 사용 중인 Buffer 메모리 크기 |
| `jvm_buffer_total_capacity_bytes` | 확보된 전체 Buffer 메모리 크기 |

📌 **Direct Buffer는 네트워크 I/O 및 파일 I/O에서 성능 최적화를 위해 사용됨.**  
📌 **Mapped Buffer는 대용량 파일을 효율적으로 처리할 때 사용됨.**  
📌 **두 버퍼 모두 GC의 영향을 받지 않으므로, 메모리 누수를 모니터링하는 것이 중요함.**

---

## 🔥 **왜 이 4개의 메트릭이 중요한가?**
✔ **Direct Buffer 모니터링이 필요한 이유**
- 네트워크 또는 파일 전송을 많이 하는 애플리케이션에서 Direct Buffer 사용량이 급증할 수 있음.
- Direct Buffer가 과도하게 증가하면 OS 메모리 부족 현상이 발생할 수 있음.
- **버퍼 메모리를 반환하지 않는 문제가 있으면, 메모리 누수가 발생할 가능성이 있음.**

✔ **Mapped Buffer 모니터링이 필요한 이유**
- Mapped Buffer는 **파일을 메모리에 매핑하여 처리하는 기술**로, 대량의 파일을 처리할 때 유용함.
- 하지만, **Mapped Buffer가 너무 많아지면 OS의 메모리 사용량이 증가하여 성능 저하가 발생할 가능성이 있음.**
- GC의 영향을 받지 않기 때문에, 직접적인 관리가 필요함.

✔ **두 버퍼를 함께 모니터링하면 JVM의 메모리 사용 최적화 가능**
- **Used 값이 Total Capacity에 근접하면, 추가적인 Buffer 할당이 필요할 수 있음.**
- **Total Capacity가 불필요하게 크다면, 메모리 낭비가 발생할 수 있음.**

---

## 📌 **Grafana에서 JVM 버퍼 메모리 모니터링 대시보드 설정**
### 🖥️ **패널 설정**
- **패널 유형:** Line Chart
- **X축:** 시간 (Timestamp)
- **Y축:** 메모리 크기 (Bytes)
- **PromQL 쿼리:**
    - **현재 사용 중인 Direct Buffer 메모리**
      ```promql
      jvm_buffer_memory_used_bytes{instance="$instance", application="$application", id="direct"}
      ```
    - **확보된 전체 Direct Buffer 용량**
      ```promql
      jvm_buffer_total_capacity_bytes{instance="$instance", application="$application", id="direct"}
      ```
    - **현재 사용 중인 Mapped Buffer 메모리**
      ```promql
      jvm_buffer_memory_used_bytes{instance="$instance", application="$application", id="mapped"}
      ```
    - **확보된 전체 Mapped Buffer 용량**
      ```promql
      jvm_buffer_total_capacity_bytes{instance="$instance", application="$application", id="mapped"}
      ```

### 🚨 **임계값(Threshold) 설정**
- **Used 값이 Total Capacity의 80% 이상** → 🟠 **주의 (메모리 부족 가능성)**
- **Used 값이 Total Capacity와 거의 같음** → 🔴 **위험 (버퍼 부족으로 성능 저하 가능)**
- **Used 값이 지속적으로 증가** → 🟠 **메모리 누수 가능성 확인 필요**

📌 **Direct Buffer와 Mapped Buffer를 모두 모니터링하여 JVM의 성능을 최적화해야 함!**  
📌 **버퍼 메모리 사용량이 비정상적으로 높다면, GC나 메모리 관리 전략을 조정해야 함!**

---

## ✅ **결론**
✔ **Direct Buffer는 네트워크 및 파일 I/O 성능을 위해 사용되며, 모니터링이 필수적!**  
✔ **Mapped Buffer는 대용량 파일 처리 시 OS 메모리 영향을 받으므로 주의해야 함!**  
✔ **Used 값과 Total Capacity를 비교하여 메모리 누수 및 성능 저하를 예방 가능!**  
✔ **Grafana에서 JVM 버퍼 메모리 모니터링을 통해 안정적인 서비스 운영 가능!**

</details>



### 부록
<details>
<summary>Metaspace, Compressed Class 차이 </summary>

1. Metaspace
    - JDK 8부터 등장 (JDK 7까지는 PermGen)
    - 클래스 메타데이터(Class Metadata)를 저장하는 공간
    - 네이티브 메모리(Native Memory) 영역에 존재
    - 기본적으로 메모리 크기가 제한되지 않고, OS가 허용하는 한 동적으로 확장됨 (-XX:MaxMetaspaceSize로 제한 가능)

2. Compressed Class Space
    - Metaspace 내부의 일부 영역
    - 64비트 JVM에서 Compressed Class Pointer(압축된 클래스 포인터, 32비트 크기) 를 사용할 때 필요
    - 기본적으로 `-XX:+UseCompressedClassPointers` 옵션이 활성화되어 있으면 사용됨
    - 클래스의 메서드 테이블, 상속 정보 등 클래스 포인터 관련 정보를 저장하는 공간
    - 크기가 고정적이며 `-XX:CompressedClassSpaceSize` 옵션으로 설정 가능


Compressed Class Space는 Metaspace의 일부이며, 클래스 포인터 관련 데이터만 저장하는 공간이다.
Metaspace는 클래스 메타데이터 전반을 저장하는 더 넓은 개념이고, Compressed Class Space는 그 안에서 특정 용도로만 사용된다.
Compressed Class Space 크기는 고정(-XX:CompressedClassSpaceSize), Metaspace는 동적(-XX:MaxMetaspaceSize).

</details>

<details>
<summary>Jvm Code Heap </summary>
# JVM Non-Heap Memory - Code Heap

## 🚀 JVM의 Code Heap 3가지

JVM의 Just-In-Time (JIT) 컴파일러가 생성한 **바이트코드를 네이티브 코드로 변환한 후 저장하는 영역**이다.  
JDK 9부터 **Code Heap이 3가지 영역**으로 나뉜다.

### 1. **Non-Profiled Code Heap**
- JIT 컴파일러가 **프로파일링 없이 컴파일한 코드**를 저장하는 공간
- 대부분의 **메서드 핸들(Method Handle), 인터프리터(Interpreter), 초기 컴파일된 코드** 등이 들어감
- 상대적으로 최적화가 덜 된 코드가 저장됨

### 2. **Profiled Code Heap**
- **프로파일링을 통해 자주 실행된 코드(Hot Code)를 저장하는 공간**
- 메서드 호출 횟수가 일정 임계치를 넘으면 **C1 컴파일러가 프로파일링하면서 네이티브 코드로 변환**
- 이후 C2 컴파일러(JVM의 최적화 컴파일러)가 더 강력한 최적화를 진행할 수도 있음

### 3. **Non-NMethods Code Heap**
- **JVM 내부적으로 사용되는 네이티브 코드**를 저장하는 공간
- 예를 들면, **JVM의 intrinsic 함수, C++로 작성된 네이티브 코드, 특정한 런타임 기능과 관련된 코드**가 들어간다.
- 일반적인 Java 애플리케이션 코드와 직접적인 관계는 없음

---

## 🎯 왜 Code Heap을 3개로 나눴을까?
JDK 9부터 이 구조가 도입된 이유는 **성능 최적화** 때문이다.

✅ **Code Heap을 세분화하면?**
- 프로파일링된 코드와 그렇지 않은 코드를 분리하여 **캐시 활용도를 높일 수 있음**
- 특정 영역이 과도하게 커지는 것을 방지하여 **JIT 컴파일러의 효율적인 메모리 관리 가능**
- 메서드 핸들, 네이티브 코드 등의 공간을 별도로 관리하여 **GC의 영향을 받지 않도록 설계**

---

## 🔍 Code Heap 크기 조절 옵션

JVM에서는 Code Heap 크기를 설정할 수 있는 몇 가지 JVM 옵션이 있다.

```bash
-XX:InitialCodeCacheSize=32m   # 초기 Code Heap 크기
-XX:ReservedCodeCacheSize=256m # 최대 Code Heap 크기
-XX:+PrintCodeCache            # 현재 Code Heap 상태 출력
```

---

## 🛠 Code Heap 관련 JVM 모니터링 방법

### 1. **JVM 옵션 사용**
```bash
-XX:+UnlockDiagnosticVMOptions -XX:+PrintCodeCache
```
위 옵션을 주고 실행하면, JVM이 Code Heap 영역을 어떻게 사용하고 있는지 볼 수 있다.

### 2. **JVisualVM 활용**
- `JVisualVM`을 실행한 후 **Metaspace와 함께 Code Cache를 모니터링** 가능

### 3. **JFR (Java Flight Recorder)**
- `jcmd <PID> VM.native_memory summary` 명령어를 사용하여 Non-Heap 영역을 상세히 확인 가능

---

## 📌 정리

- JVM의 **Non-Heap Memory**에 속하는 **Code Heap**은 3가지로 나뉜다.
    1. **Non-Profiled Code Heap** → 프로파일링 없이 컴파일된 코드 저장
    2. **Profiled Code Heap** → 프로파일링된 핫 코드 저장
    3. **Non-NMethods Code Heap** → JVM 자체 네이티브 코드 저장
- JDK 9부터 도입된 이 구조는 **JIT 성능 최적화**와 **메모리 효율 개선**을 목적으로 함.
- **JVM 옵션**이나 **JVisualVM, JFR** 등을 사용하여 모니터링 가능.

🔥 **JVM 내부 구조를 튜닝하려면 Code Heap 활용도 모니터링하는 게 중요하다!** 🚀

</details>

