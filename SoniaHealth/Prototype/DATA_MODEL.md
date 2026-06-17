# Sonia Health — Prototype Data Model

시드 데이터 스키마. `Resources/SeedData/sonia_seed.json`이 단일 진실 소스(SSOT)이고
`Models/SeedModels.swift`가 이를 그대로 디코딩한다. 모든 키는 **camelCase**, 날짜는 **ISO-8601 문자열**.

```
SeedRoot
├─ meta            메타 정보 (앱명, today, timezone, schemaVersion)
├─ user            UserProfile (페르소나 1명)
├─ voices[]        TherapistVoice (6개 보이스, Cartesia 매핑)
├─ assessments[]   Assessment (GAD-7 온보딩 / 2주차)
├─ insights[]      Insight (Sonia가 발견한 패턴 = "기억" 기능)
├─ engagement      Engagement (연속 사용일·완료율 등 통계)
└─ sessions[]      Session (아침/저녁 체크인 + 딥세션, 시간순)
```

---

## meta
| 필드 | 타입 | 설명 |
|------|------|------|
| appName | string | "Sonia" |
| schemaVersion | int | 현재 1 |
| today | string(ISO date) | 데모 기준 "오늘" = 2026-06-16 |
| timezone | string | "America/Los_Angeles" |
| notes | string | 자유 메모 |

## user (UserProfile)
| 필드 | 타입 | 설명 |
|------|------|------|
| id | string | "user_sarah" |
| displayName / firstName | string | 표시명 |
| age | int | 34 |
| pronouns | string | "she/her" |
| location | string | "Portland, OR" |
| timezone | string | IANA tz |
| occupationStatus | string | "laid_off_job_seeking" |
| joinedAt | string(ISO) | 가입 시각 |
| backstory | string | 1–2문장 배경 |
| presentingConcerns | string[] | 표면 고민 |
| goals | string[] | 목표 |
| riskLevel | string | "low" (위기 없음) |
| preferredVoiceId | string | 선택한 보이스 → voices[].id |
| preferences | UserPreferences | 아래 |

### UserPreferences
| 필드 | 타입 | 설명 |
|------|------|------|
| morningTime / eveningTime | string("HH:mm") | 리마인더 시각 |
| defaultMorningModality | "text" \| "voice" | 아침 기본 입력 |
| defaultEveningModality | "text" \| "voice" | 저녁 기본 입력 |

## voices[] (TherapistVoice)
| 필드 | 타입 | 설명 |
|------|------|------|
| id | string | "voice_aria" 등 |
| name | string | 표시 이름 |
| gender | "female"\|"male"\|"nonbinary" | |
| ageRange | string | "30s" 등 |
| style | string | "warm, grounding" 등 |
| descriptor | string | 한 줄 소개 |
| sampleLine | string | 미리듣기 대사 |
| cartesiaVoiceId | string \| null | **TODO**: Cartesia 실제 voice id (Documents/Cartesia 참고) |

> 6개 보이스는 실제 Sonia의 "6 therapists (male/female, young/older, 다양한 스타일)" 구성을 반영.
> `cartesiaVoiceId`는 플레이스홀더 — 음성 패널에서 실제 Cartesia voice UUID로 채운다.

## assessments[] (Assessment)
| 필드 | 타입 | 설명 |
|------|------|------|
| id | string | |
| type | string | "GAD-7" |
| date | string(ISO date) | |
| score | int | 0–21 |
| severity | string | "minimal"\|"mild"\|"moderate"\|"severe" |
| administeredBy | string | "onboarding" \| "biweekly_checkin" |

## insights[] (Insight) — "기억/패턴" 기능
| 필드 | 타입 | 설명 |
|------|------|------|
| id | string | |
| createdAt | string(ISO) | |
| category | string | "pattern"\|"strength"\|"theme" |
| title | string | 카드 제목 |
| body | string | 본문 |
| evidenceSessionIds | string[] | 근거가 된 sessions[].id |

## engagement (Engagement)
| 필드 | 타입 | 설명 |
|------|------|------|
| firstActiveDate / lastActiveDate | string(ISO date) | |
| daysActive | int | 활동한 일수 |
| currentStreak / longestStreak | int | 연속 사용일 |
| totalSessions | int | |
| morningCheckins / eveningCheckins / deepSessions | int | 종류별 카운트 |
| completionRate | double | 0.0–1.0 (가능했던 체크인 대비 완료율) |

## sessions[] (Session) — 핵심 단위
| 필드 | 타입 | 설명 |
|------|------|------|
| id | string | "s_d01_intake" 등 |
| kind | string | **"morningCheckin" \| "eveningCheckin" \| "deepSession"** |
| dayIndex | int | 1–15 |
| date | string(ISO date) | |
| partOfDay | "morning" \| "evening" | |
| startedAt | string(ISO datetime) | |
| durationSec | int | 길이(초) |
| modality | "text" \| "voice" | 입력 방식 |
| voiceId | string \| null | 음성일 때 사용 보이스 |
| moodBefore / moodAfter | MoodPoint \| null | 세션 전/후 기분 |
| primaryTheme | string | 대표 주제 |
| topics | string[] | 세부 주제 태그 |
| steps | string[] | 가이드 단계 (moodCheck, intentionSetting, reflection, reframe, windDown ...) |
| techniques | string[] | 사용된 기법 |
| userShared | string | 유저가 공유한 내용 요약 |
| soniaReflection | string | Sonia의 반영/응답 요약 |
| intention | string \| null | (아침) 오늘의 의도 |
| reflection | string \| null | (저녁) 하루 회고 한 줄 |
| actionItem | string \| null | 작은 실행 과제 |
| summary | string \| null | (딥세션) 세션 요약 |
| highlights | string[] | 핵심 takeaway 불릿 |
| homework | string \| null | CBT homework |
| transcriptKind | "full"\|"excerpt"\|"none" | 트랜스크립트 수록 형태 |
| transcript | TranscriptTurn[] | 대화 턴 |

### MoodPoint
| 필드 | 타입 | 설명 |
|------|------|------|
| score | int | 1–10 |
| label | string | "anxious", "hopeful" 등 |

### TranscriptTurn
| 필드 | 타입 | 설명 |
|------|------|------|
| role | "sonia" \| "user" | 화자 |
| text | string | 발화 |
| atOffsetSec | int \| null | 세션 시작 기준 오프셋(초) — 음성 발췌에 사용 |

---

## 음성 vs 챗 기록 방식 (요구사항 반영)

- **챗(text) 세션** → `modality: "text"`, `transcriptKind: "full"`,
  `transcript[]`에 **모든 메시지**를 `{role, text}` 턴으로 저장. (실제 채팅 로그 = 메시지 배열)
- **음성(voice) 세션** → `modality: "voice"`, `transcriptKind: "excerpt"`,
  전체 녹취 대신 **요약(`summary`/`soniaReflection`) + 핵심 발췌 턴(`atOffsetSec` 포함)**만 저장.
  (실제 앱도 30분 음성을 통째로 보여주지 않고 요약+하이라이트로 기록)
- 짧은 체크인은 `transcriptKind: "none"`으로 두고 구조화 필드(userShared/soniaReflection)만 채울 수 있음.

이 분리로 "챗이면 어떻게 기록되고, 음성이면 어떻게 기록되는가"를 모두 시연한다.
